abc=xlsread('heartveri.xlsx');
veri=transpose(abc);
egitim=veri(1:13,1:189);
test=veri(1:13,190:270);
egitimtarget=veri(14:15,1:189);
testtarget=veri(14:15,190:270);
wb=rand(12,13);%ara katman agirliklari
deltawb=zeros(size(wb));%ara katman agirliklarindaki degisim
bb=rand(12,1);%ara katman biaslari
deltabb=zeros(size(bb));%ara katman biaslarindaki degisim
opb=zeros(12,1);%ara katman cikislari
w=rand(2,12);%cikis katmani agirliklari
deltaw=zeros(size(w));%cikis katmani agirliklarindaki degisim
b=rand(2,1);%cikis katmani biaslari
deltab=zeros(size(b));%cikis katmani biaslarindaki degisim
op=zeros(2,1);%cikis katmani ciktisi (ysa ciktisi)
rp=zeros(2,1);%cikis katmani hata faktorleri

for k=1:length(egitim)
    hata=1;
    while (hata>0.01)
        %ara katman cikislarinin bulunmasi
        for i=1:12
            top=0;
            for n=1:13
                top=top+egitim(n,k)*wb(i,n);
            end
            opb(i)=f(top+bb(i));
        end
        %cikis katmani cikislarinin bulunmasi
        for n=1:2
            top=0;
            for i=1:12
                top=top+opb(i)*w(n,i);
            end
            op(n)=f(top+b(n));
        end
        %cikis katmani guncellemeleri
        %cikis hata faktorlerinin hesaplanmasi
        n=0.5; %ogrenme orani
        for i=1:2
            rp(i)=(egitimtarget(i,k)-op(i))*op(i)*(1-op(i));
        end
        %cikis agirliklarinin guncellenmesi
        for j=1:2
            for i=1:12
                deltaw(j,i)=n*rp(j)*opb(i);
            end
        end
        w=w+deltaw;
        %cikis katmani biaslarinin guncellenmesi
        for j=1:2
            deltab(j)=n*rp(j);
            b(j)=b(j)+deltab(j);
        end
        %%ara katman guncellemeleri
        %ara katman agirliklarinin guncellenmesi
        for i=1:12
            for j=1:13
                deltawb(i,j)=n*opb(i)*(1-opb(i))*w(1,i)*rp(1)*egitim(j,k);
                wb(i,j)=wb(i,j)+deltawb(i,j);
                deltawb(i,j)=n*opb(i)*(1-opb(i))*wb(2,j)*rp(2)*egitim(j);
                wb(i,j)=wb(i,j)+deltawb(i,j);
            end
        end
        %ara katman biaslarinin güncellenmesi
        for i=1:12
            deltabb(i)=n*opb(i)*(1-opb(i))*w(1,i)*rp(1);
            bb(i)=bb(i)+deltabb(i);
            deltab(i)=n*opb(i)*(1-opb(i))*w(2,i)*rp(2);
            bb(i)=bb(i)+deltabb(i);
        end
         hata=(1/2)*((egitimtarget(1,k)-op(1))^2+(egitimtarget(2,k)-op(2))^2);
    end
end
%%TEST ASAMASI
dogru=0;
for k=1:length(test)
    %ara katman cikislarinin bulunmasi
    for i=1:12
        top=0;
        for a=1:13
            top=top+test(a,k)*wb(i,a);
        end
        opb(i)=f(top+bb(i));
    end
    %cikis katmanlarinin bulunmasi
    for a=1:2
        top=0;
        for i=1:12
            top=top+opb(i)*w(a,i);
        end
        op(a)=f(top+b(a));
    end
    for i=1:2
        if op(i)>0.9
            op(i)=1;
        else
            op(i)=0;
        end
    end
    if (testtarget(1,k)==op(1))&&(testtarget(2,k)==op(2))
        dogru=dogru+1;
    end
end
fprintf('Verilen test setine göre agin basari orani %f tir. \n',100*dogru/length(test));
fprintf('verilen test setine göre agin hata orani %f dir. \n',(100*hata/length(test)));