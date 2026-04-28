import torch
from torch import nn
import inspect
from cornucopia.utils import warps
from utils.utils_vesselseg import ensure_list

class Upsample(nn.Module):
    """Upsample a tensor using corners as anchors"""

    def __init__(self, factor=2, anchor='center'):
        """

        Parameters
        ----------
        factor : int, Upsampling factor
        anchor : {'center', 'edge'}
            Use the center or the edges of the corner voxels as anchors

        """
        super().__init__()
        self.factor = factor
        self.anchor = anchor

    def forward(self, image, shape=None):
        """

        Parameters
        ----------
        image : (B, D, *shape) tensor
        shape : list[int], optional

        Returns
        -------
        image : (B, D, *shape) tensor

        """
        factor = None if shape else self.factor
        return warps.upsample(image, factor, shape, self.anchor)


class Downsample(nn.Module):
    """Downsample a tensor using corners as anchors"""

    def __init__(self, factor=2, anchor='center'):
        """

        Parameters
        ----------
        factor : int, Downsampling factor
        anchor : {'center', 'edge'}
            Use the center or the edges of the corner voxels as anchors

        """
        super().__init__()
        self.factor = factor
        self.anchor = anchor

    def forward(self, image, shape=None):
        """

        Parameters
        ----------
        image : (B, D, *shape) tensor
        shape : list[int], optional

        Returns
        -------
        image : (B, D, *shape) tensor

        """
        factor = None if shape else self.factor
        return warps.downsample(image, factor, shape, self.anchor)


class UpsampleConvLike(nn.Module):
    """Upsample an image the same way a transposed convolution would"""

    def __init__(self, kernel_size, stride=2, padding=0):
        """

        Parameters
        ----------
        kernel_size : [list of] int
        stride : [list of] int
        padding : [list of] int

        """
        super().__init__()
        self.kernel_size = kernel_size
        self.stride = stride
        self.padding = padding

    def forward(self, flow, shape=None):
        """

        Parameters
        ----------
        flow : (B, D, *shape) tensor
        shape : list[int], optional

        Returns
        -------
        flow : (B, D, *shape) tensor

        """
        return warps.upsample_convlike(
            flow,  self.kernel_size, self.stride, self.padding, shape)


class DownsampleConvLike(nn.Module):
    """Downsample an image the same way a strided convolution would"""

    def __init__(self, kernel_size, stride=2, padding=0):
        """

        Parameters
        ----------
        kernel_size : [list of] int
        stride : [list of] int
        padding : [list of] int

        """
        super().__init__()
        self.kernel_size = kernel_size
        self.stride = stride
        self.padding = padding

    def forward(self, flow):
        """

        Parameters
        ----------
        flow : (B, D, *shape) tensor

        Returns
        -------
        flow : (B, D, *shape) tensor

        """
        return warps.downsample_convlike(
            flow, self.kernel_size, self.stride, self.padding)

class SeparableConv(nn.Sequential):
    """
    Separable Convolution
    """

    def __init__(self, ndim, in_channels, out_channels, kernel_size=3,
                 dilation=1, bias=True, padding_mode='zeros'):
        """
        Parameters
        ----------
        ndim : int
        in_channels : int
        out_channels : int
        kernel_size : [sequence of] int
        dilation : [sequence of] int
        bias : bool
        padding_mode : {'zeros', 'reflect', 'replicate', 'circular'}
        """
        kernel_size = ensure_list(kernel_size, ndim)
        dilation = ensure_list(dilation, ndim)
        klass = getattr(nn, f'Conv{ndim}d')

        layers = []
        for dim, (K, D) in enumerate(zip(kernel_size, dilation)):
            K1 = [1] * ndim
            K1[dim] = K
            kwargs = dict(kernel_size=K1, dilation=D,
                          padding='same', bias=bias and (dim == ndim-1),
                          padding_mode=padding_mode)
            layers.append(klass(in_channels, out_channels, **kwargs))

        super().__init__(*layers)


class CrossHairConv(SeparableConv):
    """
    Separable Cross-Hair Convolution

    References
    ----------
    "DeepVesselNet: Vessel Segmentation, Centerline Prediction,
    and Bifurcation Detection in 3-D Angiographic Volumes"
    Tetteh et al
    Front. Neurosci. (2020)
    https://www.frontiersin.org/articles/10.3389/fnins.2020.592352/full
    """

    def forward(self, x):
        y = 0
        for layer in self:
            y += layer(x)
        return y


class ConvBlockBase(nn.Sequential):
    """Base class for convolution blocks (i.e. Norm+Conv+Dropout+Activation),
    with or without strides/transpose"""

    def __init__(self, ndim, in_channels, out_channels, opt_conv=None,
                 activation='ReLU', norm=None, dropout=False, order='ncda',
                 separable=False):
        super().__init__()
        self.order = self.fix_order(order)
        conv = self.make_conv(ndim, in_channels, out_channels,
                              opt_conv or {}, separable)
        norm = self.make_norm(norm, ndim, conv, self.order)
        dropout = self.make_dropout(dropout, ndim)
        activation = self.make_activation(activation)

        # Assign submodules in order
        for o in self.order:
            if o == 'n':
                self.norm = norm
            elif o == 'c':
                self.conv = conv
            elif o == 'd':
                self.dropout = dropout
            elif o == 'a':
                self.activation = activation

    @staticmethod
    def fix_order(order):
        order = order.lower()
        if 'n' not in order:
            order = order + 'n'
        if 'c' not in order:
            order = order + 'c'
        if 'd' not in order:
            order = order + 'd'
        if 'a' not in order:
            order = order + 'a'
        return order

    @staticmethod
    def make_conv(ndim, in_channels, out_channels, opt_conv, separable):
        transpose = opt_conv.pop('transpose', False)
        if separable:
            if transpose or 'stride' in opt_conv.get('stride', 1) != 1:
                raise ValueError('Separable convolutions cannot be '
                                 'strided or transposed')
            if isinstance(separable, str) and separable.lower().startswith('cross'):
                conv_klass = CrossHairConv
            else:
                conv_klass = SeparableConv
        else:
            conv_klass = (getattr(nn, f'ConvTranspose{ndim}d') if transpose else
                          getattr(nn, f'Conv{ndim}d'))
        opt_conv['kernel_size'] = ensure_list(opt_conv['kernel_size'], ndim)
        if 'dilation' in opt_conv:
            opt_conv['dilation'] = ensure_list(opt_conv['dilation'], ndim)
        conv = conv_klass(in_channels, out_channels, **opt_conv)
        return conv

    @staticmethod
    def make_activation(activation):
        #   an activation can be a class (typically a Module), which is
        #   then instantiated, or a callable (an already instantiated
        #   class or a more simple function).
        #   it is useful to accept both these cases as they allow to either:
        #       * have a learnable activation specific to this module
        #       * have a learnable activation shared with other modules
        #       * have a non-learnable activation
        if not activation:
            return None
        if isinstance(activation, str):
            activation = getattr(nn, activation)
        activation = (activation() if inspect.isclass(activation)
                      else activation if callable(activation)
                      else None)
        return activation

    @staticmethod
    def make_dropout(dropout, ndim):
        dropout = (dropout() if inspect.isclass(dropout)
                   else dropout if callable(dropout)
                   else getattr(nn, f'Dropout{ndim}d')(p=float(dropout)) if dropout
                   else None)
        return dropout

    @staticmethod
    def make_norm(norm, ndim, conv, order):
        #   a normalization can be a class (typically a Module), which is
        #   then instantiated, or a callable (an already instantiated
        #   class or a more simple function).
        if not norm:
            return None
        if isinstance(norm, bool) and norm:
            norm = 'batch'
        in_channels = (conv.in_channels if order.index('n') < order.index('c')
                       else conv.out_channels)
        if isinstance(norm, str):
            if 'instance' in norm.lower():
                norm = getattr(nn, f'InstanceNorm{ndim}d')
            elif 'layer' in norm.lower():
                norm = nn.GroupNorm
            elif 'batch' in norm.lower():
                norm = getattr(nn, f'BatchNorm{ndim}d')
        norm = (norm(in_channels, in_channels) if norm is nn.GroupNorm
                else norm(in_channels) if inspect.isclass(norm)
                else norm if callable(norm)
                else None)
        return norm


class ConvBlock(ConvBlockBase):
    """Norm + Conv + Dropout + Activation"""

    def __init__(self, ndim, in_channels, out_channels, kernel_size=3,
                 dilation=1, bias=True, activation='ReLU', norm=None,
                 dropout=False, order='ncda', separable=False):
        """

        Notes
        -----
        .. ActivationType : None or str or class or instance
        .. NormType : None or {'batch', 'instance', 'layer'} or class or instance
        .. DropoutType : None or float (in 0..1) or class or instance
        .. order : n == norm, c == conv, d == dropout, a == activation
        .. Padding is always "same"

        Parameters
        ----------
        ndim : int, Number of spatial dimensions
        in_channels : int, Number of input features
        out_channels : int, Number of output features
        kernel_size : [list of] int, Kernel size
        bias : bool, Include a bias term
        activation : ActivationType, Activation function
        norm : NormType, Normalization function ('batch', 'instance', 'layer')
        dropout : DropoutType, Dropout probability
        order : str, Modules order (permutation of 'ncda')
        separable : bool or 'cross'
        """
        super().__init__(ndim, in_channels, out_channels,
                         activation=activation, norm=norm,
                         dropout=dropout, order=order, separable=separable,
                         opt_conv=dict(kernel_size=kernel_size,
                                       dilation=dilation,
                                       bias=bias,
                                       padding='same'))


class StridedConvBlockDown(ConvBlockBase):
    """Norm + Strided Conv + Dropout + Activation"""

    def __init__(self, ndim, in_channels, out_channels, stride=2,
                 kernel_size=None, bias=True, activation='ReLU', norm=None,
                 dropout=False, order='ncda'):
        """

        Notes
        -----
        .. ActivationType : None or str or class or instance
        .. NormType : None or {'batch', 'instance', 'layer'} or class or instance
        .. DropoutType : None or float (in 0..1) or class or instance
        .. order : n == norm, c == conv, d == dropout, a == activation

        Parameters
        ----------
        ndim : int, Number of spatial dimensions
        in_channels : int, Number of input features
        out_channels : int, Number of output features
        stride : [list of] int, Strides
        kernel_size : [list of] int, default=stride, Kernel size
        bias : bool, Include a bias term
        activation : ActivationType, Activation function
        norm : NormType, Normalization function ('batch', 'instance', 'layer')
        dropout : DropoutType, Dropout probability
        order : str, Modules order (permutation of 'ncda')
        """
        kernel_size = kernel_size or stride
        super().__init__(ndim, in_channels, out_channels,
                         activation=activation,
                         norm=norm, dropout=dropout, order=order,
                         opt_conv=dict(bias=bias,
                                       kernel_size=kernel_size,
                                       stride=stride))


class StridedConvBlockUp(ConvBlockBase):
    """Norm + Transposed Conv + Dropout + Activation"""

    def __init__(self, ndim, in_channels, out_channels, stride=2,
                 kernel_size=None, bias=True, activation='ReLU', norm=None,
                 dropout=False, order='ncda', combine='cat'):
        """

        Notes
        -----
        .. ActivationType : None or str or class or instance
        .. NormType : None or {'batch', 'instance', 'layer'} or class or instance
        .. DropoutType : None or float (in 0..1) or class or instance
        .. order : n == norm, c == conv, d == dropout, a == activation

        Parameters
        ----------
        ndim : int, Number of spatial dimensions
        in_channels : int, Number of input features
        out_channels : int, Number of output features
        stride : [list of] int, Strides
        kernel_size : [list of] int, default=stride, Kernel size
        bias : bool, Include a bias term
        activation : ActivationType, Activation function
        norm : NormType, Normalization function ('batch', 'instance', 'layer')
        dropout : DropoutType, Dropout probability
        order : str, Modules order (permutation of 'ncda')
        """
        kernel_size = kernel_size or stride
        super().__init__(ndim, in_channels, out_channels,
                         activation=activation, norm=norm,
                         dropout=dropout, order=order,
                         opt_conv=dict(bias=bias,
                                       kernel_size=kernel_size,
                                       transpose=True,
                                       stride=stride))
        self.skip = (combine if callable(combine) else
                     Cat() if combine == 'cat' else
                     Add())

    def forward(self, x, skip=None, shape=None):
        if skip is not None:
            shape = skip.shape[2:]
        shape_in = x.shape[2:]
        kernel_size = self.conv.kernel_size
        stride = self.conv.stride
        padding = self.conv.padding
        output_padding = 0
        if shape is not None:
            shape = ensure_list(shape, x.dim() - 2)
            shape_out = [(l + 2 * p - k)//s + 1 for l, k, s, p
                         in zip(shape_in, kernel_size, stride, padding)]
            output_padding = [s - so for s, so in zip(shape, shape_out)]
        self.conv.output_padding = output_padding
        x = super().forward(x)
        self.conv.output_padding = 0
        if skip is not None:
            x = self.skip(x, skip)
        return x


class ConvBlockDown(nn.Sequential):
    """Downsampled + Norm + Conv + Dropout + Activation"""

    def __init__(self, ndim, in_channels, out_channels, factor=2,
                 kernel_size=3, bias=True, activation='ReLU', norm=None,
                 dropout=False, order='ncda'):
        """

        Notes
        -----
        .. ActivationType : None or str or class or instance
        .. NormType : None or {'batch', 'instance', 'layer'} or class or instance
        .. DropoutType : None or float (in 0..1) or class or instance
        .. order : n == norm, c == conv, d == dropout, a == activation

        Parameters
        ----------
        ndim : int, Number of spatial dimensions
        in_channels : int, Number of input features
        out_channels : int, Number of output features
        factor : [list of] int, Downsampling factor
        kernel_size : [list of] int, Kernel size
        bias : bool, Include a bias term
        activation : ActivationType, Activation function
        norm : NormType, Normalization function ('batch', 'instance', 'layer')
        dropout : DropoutType, Dropout probability
        order : str, Modules order (permutation of 'ncda')
        """
        super().__init__()
        self.downsample = Downsample(factor=factor)
        self.conv = ConvBlock(ndim, in_channels, out_channels, bias=bias,
                              kernel_size=kernel_size, activation=activation,
                              norm=norm, dropout=dropout, order=order)


class ConvBlockUp(nn.Sequential):
    """Norm + Conv + Dropout + Activation + Upsample"""

    def __init__(self, ndim, in_channels, out_channels, factor=2,
                 kernel_size=3, bias=True, activation='ReLU', norm=None,
                 dropout=False, order='ncda', combine='cat'):
        """

        Notes
        -----
        .. ActivationType : None or str or class or instance
        .. NormType : None or {'batch', 'instance', 'layer'} or class or instance
        .. DropoutType : None or float (in 0..1) or class or instance
        .. order : n == norm, c == conv, d == dropout, a == activation

        Parameters
        ----------
        ndim : int, Number of spatial dimensions
        in_channels : int, Number of input features
        out_channels : int, Number of output features
        factor : [list of] int, Upsampling factor
        kernel_size : [list of] int, Kernel size
        bias : bool, Include a bias term
        activation : ActivationType, Activation function
        norm : NormType, Normalization function ('batch', 'instance', 'layer')
        dropout : DropoutType, Dropout probability
        order : str, Modules order (permutation of 'ncda')
        """
        super().__init__()
        self.conv = ConvBlock(ndim, in_channels, out_channels, bias=bias,
                              kernel_size=kernel_size, activation=activation,
                              norm=norm, dropout=dropout, order=order)
        self.upsample = Upsample(factor=factor)
        self.skip = (combine if callable(combine) else
                     Cat() if combine == 'cat' else
                     Add())

    def forward(self, x, skip=None, shape=None):
        """

        Parameters
        ----------
        x : (B, C, *shape_in) tensor
        skip : (B, C, *shape) tensor, optional
            Tensor to concatenate to the output
        shape : list[int], optional
            Target shape (not needed if `skip` provided)

        Returns
        -------
        x : (B, C, *shape) tensor

        """
        if skip is not None:
            shape = skip.shape[2:]
        x = self.conv(x)
        x = self.upsample(x, shape)
        if skip is not None:
            x = self.skip(x, skip)
        return x


class ConvGroup(nn.Module):
    """Multiple convolutions stacked together"""

    def __init__(self, ndim, in_channels, mid_channels=None, out_channels=None,
                 kernel_size=3, nb_conv=1, dilation=1, recurrent=False, residual=False,
                 bias=True, activation='ReLU', norm=None,  dropout=False,
                 order='ncda', separable=False):
        """

        Notes
        -----
        .. ActivationType : None or str or class or instance
        .. NormType : None or {'batch', 'instance', 'layer'} or class or instance
        .. DropoutType : None or float (in 0..1) or class or instance
        .. order : n == norm, c == conv, d == dropout, a == activation
        .. Padding is always "same"

        Parameters
        ----------
        ndim : int, Number of spatial dimensions
        in_channels : int, Number of input features
        mid_channels : int, default=in_channels, Number of middle features
        out_channels : int, default=mid_channels, Number of output features
        kernel_size : [list of] int, Kernel size
        nb_conv : int, Number of stacked blocks
        recurrent : bool, Share weights across blocks
        residual : bool, Add residual connections between blocks
        bias : bool, Include a bias term
        activation : ActivationType, Activation function
        norm : NormType, Normalization function ('batch', 'instance', 'layer')
        dropout : DropoutType, Dropout probability
        order : str, Modules order (permutation of 'ncda')
        separable : bool or 'cross'
        """

        super().__init__()
        self.residual = residual

        mid_channels = mid_channels or in_channels
        out_channels = out_channels or mid_channels
        nb_conv -= (in_channels != mid_channels)
        nb_conv -= (out_channels != mid_channels)

        if in_channels != mid_channels:
            self.firstconv = ConvBlock(
                ndim, in_channels, mid_channels, kernel_size,
                dilation=dilation, bias=bias, activation=activation, norm=norm,
                dropout=dropout, order=order, separable=separable)

        if recurrent:
            conv1 = ConvBlock(
                ndim, mid_channels, mid_channels, kernel_size,
                dilation=dilation, bias=bias, activation=activation, norm=norm,
                dropout=dropout, order=order, separable=separable)
            make_conv = lambda: conv1
        else:
            make_conv = lambda: ConvBlock(
                ndim, mid_channels, mid_channels, kernel_size,
                dilation=dilation, bias=bias, activation=activation, norm=norm,
                dropout=dropout, order=order, separable=separable)

        self.conv = nn.Sequential(*[make_conv() for _ in range(nb_conv)])

        if out_channels != mid_channels:
            self.lastconv = ConvBlock(
                ndim, mid_channels, out_channels, kernel_size,
                dilation=dilation, bias=bias, activation=activation, norm=norm,
                dropout=dropout, order=order, separable=separable)

    def forward(self, x, skip=None):
        firstconv = getattr(self, 'firstconv', lambda x: x)
        lastconv = getattr(self, 'lastconv', lambda x: x)

        if skip is not None:
            x = Cat()(x, skip)

        x = firstconv(x)
        if self.residual:
            for conv in self.conv:
                identity = x
                x = conv(x)
                x += identity
        else:
            x = self.conv(x)
        x = lastconv(x)
        return x

    @property
    def first_activation(self):
        if hasattr(self, 'firstconv'):
            return getattr(self.firstconv, 'activation', None)
        if len(self.conv):
            return getattr(self.conv[0], 'activation', None)
        if hasattr(self, 'lastconv'):
            return getattr(self.lastconv, 'activation', None)
        return None

    @first_activation.setter
    def first_activation(self, value):
        if hasattr(self, 'firstconv'):
            if value is None and hasattr(self.firstconv, 'activation'):
                delattr(self.firstconv, 'activation')
            else:
                self.firstconv.activation = value
        elif len(self.conv):
            if value is None and hasattr(self.conv[0], 'activation'):
                delattr(self.conv[0], 'activation')
            else:
                self.conv[0].activation = value
        elif hasattr(self, 'lastconv'):
            if value is None and hasattr(self.lastconv, 'activation'):
                delattr(self.lastconv, 'activation')
            else:
                self.lastconv.activation = value

    @property
    def last_activation(self):
        if hasattr(self, 'lastconv'):
            return getattr(self.lastconv, 'activation', None)
        if len(self.conv):
            return getattr(self.conv[-1], 'activation', None)
        if hasattr(self, 'firstconv'):
            return getattr(self.firstconv, 'activation', None)
        return None

    @last_activation.setter
    def last_activation(self, value):
        if hasattr(self, 'lastconv'):
            if value is None and hasattr(self.lastconv, 'activation'):
                delattr(self.lastconv, 'activation')
            else:
                self.lastconv.activation = value
        elif len(self.conv):
            if value is None and hasattr(self.conv[-1], 'activation'):
                delattr(self.conv[-1], 'activation')
            else:
                self.conv[-1].activation = value
        elif hasattr(self, 'firstconv'):
            if value is None and hasattr(self.firstconv, 'activation'):
                delattr(self.firstconv, 'activation')
            else:
                self.firstconv.activation = value


class EncoderBlock(nn.Sequential):

    def __init__(self, down, conv):
        super().__init__()
        self.down = down
        self.conv = conv


class DecoderBlock(nn.Sequential):

    def __init__(self, conv, up):
        super().__init__()
        self.conv = conv
        self.up = up


class Cat(nn.Module):
    """Concatenate tensors"""

    def __init__(self, dim=1):
        super().__init__()
        self.dim = dim

    def forward(self, *args):
        return torch.cat(args, self.dim)


class Add(nn.Module):
    """Add tensors"""

    def __init__(self):
        super().__init__()

    def forward(self, *args):
        return sum(args)


class Split(nn.Module):
    """Split tensor"""

    def __init__(self, nb_chunks=2, dim=1):
        super().__init__()
        self.dim = dim
        self.nb_chunks = nb_chunks

    def forward(self, x):
        return torch.tensor_split(x, self.nb_chunks, dim=self.dim)


class DoNothing(nn.Module):
    def forward(self, x, *args, **kwargs):
        return x


class Hadamard(nn.Module):
    """
    Reparameterize tensors using the Hadamard transform.

    (x, y) -> (x + y, x - y)
    """
    def forward(self, x, y=None):
        """

        Parameters
        ----------
        x : (B, C, *shape) tensor
        y : (B, C, *shape) tensor

        Returns
        -------
        h : (B, 2*C, *shape) tensor

        """
        if y is None:
            nc = x.shape[1]
            x, y = x[:, :(nc//2)], x[:, (nc//2):]
        return torch.cat([x + y, x - y], dim=1)


class SymExp(nn.Module):
    """
    Symmetric Exponential Activation

    SymExp(x) = sign(x) * (exp(|x|) - 1)
    """

    def forward(self, x):
        sign = x.sign()
        x = x.abs().exp().sub_(1).mul_(sign)
        return x


class SymLog(nn.Module):
    """
    Symmetric Logarithmic Activation

    SymLog(x) = sign(x) * log(1 + |x|)
    """

    def forward(self, x):
        sign = x.sign()
        x = x.abs().add_(1).log().mul_(sign)
        return x


class InitWeightsBase:
    """Base class for weights initializers"""

    def __init__(self):
        self.initializers = {}

    @torch.no_grad()
    def __call__(self, module):
        for klass, init in self.initializers.items():
            if isinstance(module, klass):
                init(module)


class InitWeightsKaiming(InitWeightsBase):
    """Init ConvBlocks using Kaiming He's method."""

    def __init__(self, neg_slope=1e-2):
        super().__init__()
        self.neg_slope = neg_slope
        self.initializers[ConvBlockBase] = self.init_conv

    def init_conv(self, module):
        module = module.getattr('conv', None)
        if module:
            module.weight = nn.init.kaiming_normal_(module.weight, a=self.neg_slope)
            if module.bias:
                module.bias = nn.init.constant_(module.bias, 0)

