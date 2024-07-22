------EMPRESA------------
SELECT DS_MULTI_EMPRESA FROM dbamv.multi_empresas WHERE CD_MULTI_EMPRESA = {V_CD_MULTI_EMPRESA}

------USUARIO------------
SELECT USER FROM DUAL

------------------FONTE-------------------------



SELECT c.DESCRICAO,
       c.COMPETENCIA,
       c.QT_PROCEDIMENTO,
       c.qt_atendimento,
       c.QT_DIARIA,
       c.VL_RECEITA,
       c.VL_DIARIA,
       c.VL_PROCEDIMENTO,
       c.VL_PRODUTO,
       c.VL_TERCEIRO,
       c.VL_HONORARIO,
       c.TOTAL,
       c.CST_FIXO,
       c.CST_VARIAVEL,
       c.RESULTADO,
       c.MARGEM,
       Decode (margem, 0, 0, cst_fixo / margem) ponto_equilibrio,
       ((Decode(c.vl_receita, 0, 0, c.resultado / c.vl_receita)) * 100 ) rent,
       Decode (c.qt_diaria, 0, 0, c.resultado / c.qt_diaria ) diaria,
       Decode (c.qt_atendimento, 0, 0, c.resultado / c.qt_atendimento ) paciente

  FROM (

    SELECT b.* ,
          (b.vl_receita - b.total) resultado,
          (vl_receita - cst_variavel) margem 
      FROM (

        SELECT a.descricao,
              a.cd_ordenacao,
              a.competencia ,
              Sum(a.qt_procedimento) qt_procedimento,                                     
              count(DISTINCT (a.qt_atendimento)) qt_atendimento,
              Sum(a.qt_diaria) qt_diaria,
              Sum(a.vl_receita) vl_receita,
              Sum(a.vl_diaria) vl_diaria,
              Sum(a.vl_procedimento) vl_procedimento,
              Sum(a.vl_produto) vl_produto,
              Sum(a.vl_terceiro) vl_terceiro,
              Sum(a.vl_honorario) vl_honorario,
              (Sum(a.vl_diaria) + Sum(a.vl_procedimento) + Sum(a.vl_produto) + Sum(a.vl_terceiro) + Sum(a.vl_honorario)) total,
              Sum(cst_fixo) cst_fixo,
              Sum(cst_variavel) cst_variavel      
     
        FROM (

          SELECT Decode('{V_CONSOLIDACAO}' , 'C', c.cd_convenio||'-'||c.nm_convenio, pf.cd_pro_fat||'-'||pf.ds_pro_fat) descricao,
                Decode('{V_CONSOLIDACAO}' , 'C', c.cd_convenio, pf.cd_pro_fat) cd_ordenacao,
                To_Char(Nvl(dt_alta, dt_atendimento), 'MM/YYYY') competencia,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
                Nvl((SELECT Sum(qt_item) FROM dbamv.fa_it_custo_atendimento fica2 WHERE fica.tp_item <> 'DIA' AND fica2.cd_fa_it_custo_atendimento =  fica.cd_fa_it_custo_atendimento ),0) qt_procedimento,
                Nvl((SELECT fica2.cd_atendimento FROM dbamv.fa_it_custo_atendimento fica2 WHERE fica.tp_item <> 'DIA' AND fica2.cd_fa_it_custo_atendimento =  fica.cd_fa_it_custo_atendimento ),0) qt_atendimento,
                0 qt_diaria,
             
                Nvl((SELECT Sum (vl_total_item) FROM dbamv.fa_it_custo_atendimento fica2 WHERE fica2.tp_item = 'REC' AND fica2.cd_fa_it_custo_atendimento =  fica.cd_fa_it_custo_atendimento  ),0) vl_receita,
                0 vl_diaria,
                Nvl((SELECT Sum (vl_total_item) FROM dbamv.fa_it_custo_atendimento fica2 WHERE fica2.tp_item IN ('PRO','ERX', 'ELB', 'SLC') AND fica2.cd_fa_it_custo_atendimento =  fica.cd_fa_it_custo_atendimento),0) vl_procedimento,
                Nvl((SELECT Sum (vl_total_item) FROM dbamv.fa_it_custo_atendimento fica2 WHERE fica2.tp_item IN ('MAT','GAS') AND fica2.cd_fa_it_custo_atendimento =  fica.cd_fa_it_custo_atendimento  ),0) vl_produto,
                Nvl((SELECT Sum (vl_total_item) FROM dbamv.fa_it_custo_atendimento fica2 WHERE fica2.tp_item = 'TER' AND fica2.cd_fa_it_custo_atendimento =  fica.cd_fa_it_custo_atendimento  ),0) vl_terceiro,
                Nvl((SELECT Sum (vl_total_item) FROM dbamv.fa_it_custo_atendimento fica2 WHERE fica2.tp_item IN ('HON','IMP','TAX') AND fica2.cd_fa_it_custo_atendimento =  fica.cd_fa_it_custo_atendimento  ),0) vl_honorario,
                
                Nvl((SELECT Sum(vl_total_item_fix) FROM dbamv.fa_it_custo_atendimento fica2 WHERE  fica2.tp_item <> 'DIA' AND fica2.cd_fa_it_custo_atendimento =  fica.cd_fa_it_custo_atendimento ),0) cst_fixo,
                Nvl((SELECT Sum(vl_total_item_var) FROM dbamv.fa_it_custo_atendimento fica2 WHERE  fica2.tp_item <> 'DIA' AND fica2.cd_fa_it_custo_atendimento =  fica.cd_fa_it_custo_atendimento ),0) cst_variavel
          FROM dbamv.fa_it_custo_atendimento fica,
              dbamv.convenio c,
              dbamv.pro_fat pf,
              dbamv.gru_pro gp,
              dbamv.gru_fat gf,
              dbamv.atendime am
          WHERE fica.cd_convenio = c.cd_convenio
            AND fica.cd_pro_fat = pf.cd_pro_fat 
            AND pf.cd_gru_pro = gp.cd_gru_pro                                                                                                                                                                                                                                                                                                                                                   
            AND gp.cd_gru_fat = gf.cd_gru_fat
            AND am.cd_convenio = c.cd_convenio
            AND am.cd_atendimento = fica.cd_atendimento
            AND fica.tp_item <> 'DIA'
            AND gf.cd_gru_fat = {V_CD_GRU_FAT}
            {V_DS_GRU_PRO} 
            AND fica.cd_convenio NOT IN (1,2)
            AND fica.cd_multi_empresa = {V_CD_MULTI_EMPRESA} 
            {V_DT_ATENDIMENTO}
            

          UNION ALL       ----------------------------------------------------------------------------------------
   
   
          SELECT Decode('{V_CONSOLIDACAO}' , 'C', c.cd_convenio||'-'||c.nm_convenio, ta.cd_tip_acom||'-'||ta.ds_tip_acom) descricao,
                Decode('{V_CONSOLIDACAO}' ,'C', c.cd_convenio, ta.cd_tip_acom) cd_ordenacao,
                To_Char(Nvl(dt_alta, dt_atendimento), 'MM/YYYY') competencia,
                
                Nvl((SELECT Sum(qt_item) FROM dbamv.fa_it_custo_atendimento fica2 WHERE fica.tp_item = 'DIA' AND fica2.cd_fa_it_custo_atendimento =  fica.cd_fa_it_custo_atendimento ),0) qt_procedimento,
                Nvl((SELECT fica2.cd_atendimento FROM dbamv.fa_it_custo_atendimento fica2 WHERE fica.tp_item = 'DIA' AND fica2.cd_fa_it_custo_atendimento =  fica.cd_fa_it_custo_atendimento ),0) QT_ATENDIMENTO,
                Nvl((SELECT Sum(qt_item) FROM dbamv.fa_it_custo_atendimento fica2 WHERE tp_item = 'DIA' AND fica2.cd_fa_it_custo_atendimento =  fica.cd_fa_it_custo_atendimento ),0) qt_diaria,
                
                0 vl_receita,
                Nvl((SELECT Sum (vl_total_item) FROM dbamv.fa_it_custo_atendimento fica2 WHERE fica2.tp_item = 'DIA' AND fica2.cd_fa_it_custo_atendimento =  fica.cd_fa_it_custo_atendimento),0) vl_diaria,
                0 vl_procedimento,
                0 vl_produto,
                0 vl_terceiro,
                0 vl_honorario,

                Nvl((SELECT Sum(vl_total_item_fix) FROM dbamv.fa_it_custo_atendimento fica2 WHERE fica2.tp_item = 'DIA' AND fica2.cd_fa_it_custo_atendimento =  fica.cd_fa_it_custo_atendimento),0) cst_fixo,
                Nvl((SELECT Sum(vl_total_item_var) FROM dbamv.fa_it_custo_atendimento fica2 WHERE fica2.tp_item = 'DIA' AND fica2.cd_fa_it_custo_atendimento =  fica.cd_fa_it_custo_atendimento),0) cst_variavel
          FROM dbamv.fa_it_custo_atendimento fica,
              dbamv.convenio c,
              dbamv.tip_acom ta,
              dbamv.atendime am
          WHERE fica.cd_convenio = c.cd_convenio                                                                       
            AND fica.cd_tip_acom = ta.cd_tip_acom
            AND am.cd_convenio = c.cd_convenio
            AND am.cd_atendimento  = fica.cd_atendimento
            AND fica.tp_item = 'DIA'
            AND fica.cd_convenio NOT IN (1,2)
            AND fica.cd_multi_empresa = {V_CD_MULTI_EMPRESA} 
            {V_DT_ATENDIMENTO}
                                                                                                                                                                                                                                                                                                                                              

        ) a                    
        GROUP BY competencia, descricao, cd_ordenacao

    ) b
                                                                                        

) c
ORDER BY competencia {V_ORDENACAO}


                                              