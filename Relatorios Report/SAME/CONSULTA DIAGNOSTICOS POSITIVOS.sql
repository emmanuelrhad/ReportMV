SELECT  FROM (
SELECT VDIC_PESQUISA_DIAGNOSTICO_HNL.CAD, 
       VDIC_PESQUISA_DIAGNOSTICO_HNL.SAME, 
       VDIC_PESQUISA_DIAGNOSTICO_HNL.PACIENTE, 
       VDIC_PESQUISA_DIAGNOSTICO_HNL.IDADE, 
       VDIC_PESQUISA_DIAGNOSTICO_HNL.CIDADE, 
       VDIC_PESQUISA_DIAGNOSTICO_HNL.BAIRRO, 
       VDIC_PESQUISA_DIAGNOSTICO_HNL.SITUAÇÃO, 
       VDIC_PESQUISA_DIAGNOSTICO_HNL.CID, 
       VDIC_PESQUISA_DIAGNOSTICO_HNL.CID_DESCRICAO, 
       VDIC_PESQUISA_DIAGNOSTICO_HNL.SEXO, 
       VDIC_PESQUISA_DIAGNOSTICO_HNL.DT_LAUDO, 
       VDIC_PESQUISA_DIAGNOSTICO_HNL.USUARIOMV, 
       COUNT() COUNT_2
FROM 
     DBAMV.VDIC_PESQUISA_DIAGNOSTICO_HNL VDIC_PESQUISA_DIAGNOSTICO_HNL
WHERE 
      ( VDIC_PESQUISA_DIAGNOSTICO_HNL.CID LIKE 'C%' )
       AND ( VDIC_PESQUISA_DIAGNOSTICO_HNL.DT_LAUDO BETWEEN TO_DATE('20120101','YYYYMMDD') AND TO_DATE('20301231','YYYYMMDD') )
GROUP BY VDIC_PESQUISA_DIAGNOSTICO_HNL.CAD, 
         VDIC_PESQUISA_DIAGNOSTICO_HNL.SAME, 
         VDIC_PESQUISA_DIAGNOSTICO_HNL.PACIENTE, 
         VDIC_PESQUISA_DIAGNOSTICO_HNL.IDADE, 
         VDIC_PESQUISA_DIAGNOSTICO_HNL.CIDADE, 
         VDIC_PESQUISA_DIAGNOSTICO_HNL.BAIRRO, 
         VDIC_PESQUISA_DIAGNOSTICO_HNL.SITUAÇÃO, 
         VDIC_PESQUISA_DIAGNOSTICO_HNL.CID, 
         VDIC_PESQUISA_DIAGNOSTICO_HNL.CID_DESCRICAO, 
         VDIC_PESQUISA_DIAGNOSTICO_HNL.SEXO, 
         VDIC_PESQUISA_DIAGNOSTICO_HNL.DT_LAUDO, 
         VDIC_PESQUISA_DIAGNOSTICO_HNL.USUARIOMV
) Q
WHERE Q.CID LIKE '{CID}'
AND Q.DT_LAUDO  BETWEEN @P_DT_LAUDO_INI AND @P_DT_LAUDO_FIM