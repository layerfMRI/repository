

PTA -prefix d1 -input d1.tbl \
    -model 's(layer)+s(layer,by=Condition)+s(run,bs="re")' \
    -vt run 's(run)' -Y Value                             \
    -prediction p1.tbl
 
#foplotting

cp d1-prediction.txt d1-prediction.1D

#1dplot  -ok_1D_text -plabel 'conditon 1'  'd1-prediction.1D[4]{1..10}' 
#1dplot  -ok_1D_text -plabel 'conditon 2'  'd1-prediction.1D[4]{11..20}' 

#1dplot  -ok_1D_text -plabel 'conditon 1' -ps  'd1-prediction.1D[4]{1..10}'  > condition1.ps
#1dplot  -ok_1D_text -plabel 'conditon 2' -ps  'd1-prediction.1D[4]{11..20}' > condition2.ps

#1dplot  -ok_1D_text -censor_RGB red -CENSORTR 1-10  -censor_RGB blue -CENSORTR 11-20 -plabel 'RED cond 1 --- BLUE cond 2' 'd1-prediction.1D[4]'
