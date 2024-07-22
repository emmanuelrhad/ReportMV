------EMPRESA------------
SELECT DS_MULTI_EMPRESA FROM dbamv.multi_empresas WHERE CD_MULTI_EMPRESA = {V_CD_MULTI_EMPRESA}

------USUARIO------------
SELECT USER FROM DUAL

------------------FONTE-------------------------
SELECT cd_atendimento,
       ds_paciente,
       ds_convenio,
       tp_referencia,
       item_referencia,
       ds_referencia,
       ds_unidade,
       qt_item,
       rec_unit,
       rec_total,
       cst_unit,
       cst_total,
       (Nvl(rec_total, 0)-Nvl(cst_total, 0)) v_resultado,
       dt_atendimento,
       dt_alta
  FROM (
  SELECT a.cd_atendimento cd_atendimento,
          p.cd_paciente||' - '||p.nm_paciente ds_paciente,
          c.cd_convenio||' - '||c.nm_convenio ds_convenio,
          Decode(SubStr(a.cd_origem,1,3),'PRO','PROCEDIMENTO',
                                        'TER','PROCEDIMENTO',
                                        'DIA','DIARIA',
                                        'ERX','EXAME DE IMAGEM',
                                        'ELB','EXAME LABORATORIAL',
                                        'SLC','CIRURGIA',
                                        'MAT','ITEM UTILIZADO',
                                        'GAS','ITEM UTILIZADO',
                                        'IMP','CUSTO APROPRIADO',
                                        'TAX','CUSTO APROPRIADO',
                                        'HON','SERVICO EXECUTADO') tp_referencia,
          a.item_referencia,
          Decode(SubStr(a.cd_origem,1,3),'PRO', pf.ds_pro_fat,
                                        'HON', 'HONORARIOS MEDICOS',
                                        'TER', pf.ds_pro_fat,
                                        'GAS', pr.ds_produto,
                                        'DIA', ta.ds_tip_acom,
                                        'SLC', cr.ds_cirurgia,
                                        'ERX', rx.ds_exa_rx,
                                        'ELB', lb.nm_exa_lab,
                                        'MAT', pr.ds_produto,
                                        'IMP', re.ds_item_res,
                                        'TAX', re.ds_item_res) ds_referencia ,
          Decode(SubStr(a.cd_origem,1,3),'REC','UNIDADE',
                                        'PRO','UNIDADE',
                                        'TER','UNIDADE',
                                        'DIA','UNIDADE',
                                        'ERX','UNIDADE',
                                        'ELB','UNIDADE',
                                        'SLC','MINUTO',
                                        'MAT',(SELECT DS_UNIDADE FROM dbamv.uni_pro WHERE tp_relatorios = 'R' AND cd_produto = a.item_referencia),
                                        'GAS',(SELECT DS_UNIDADE FROM dbamv.uni_pro WHERE tp_relatorios = 'R' AND cd_produto = a.item_referencia),
                                        'IMP','MOEDA',
                                        'TAX','MOEDA',
                                        'HON','MOEDA') ds_unidade,
          a.qt_item,
          (SELECT Sum(vl_unit_item)
            FROM dbamv.fa_it_custo_atendimento f
            WHERE tp_item = 'REC'
              {V_CD_ATENDIMENTO}
              AND f.cd_pro_fat = a.cd_pro_fat) rec_unit ,
          (SELECT Sum(vl_total_item)
            FROM dbamv.fa_it_custo_atendimento f
            WHERE tp_item = 'REC'
              {V_CD_ATENDIMENTO}
              AND f.cd_pro_fat = a.cd_pro_fat) rec_total,
          a.cst_unit,
          a.cst_total,
          To_Char(b.dt_atendimento, 'DD/MM/YYYY') dt_atendimento,
          To_Char(Nvl(b.dt_alta, b.dt_atendimento), 'DD/MM/YYYY') dt_alta
  FROM (SELECT cd_atendimento,
                cd_convenio,
                cd_pro_fat,
                SubStr(cd_origem,5,99) item_referencia,
                cd_origem,                                                                                             
                qt_item,
                0 rec_unit,
                0 rec_total,
                Decode(tp_item,'REC', 0, vl_unit_item) cst_unit,
                Decode(tp_item,'REC', 0, vl_total_item) cst_total
          FROM dbamv.fa_it_custo_atendimento
        WHERE tp_item <> 'REC'
          {V_CD_ATENDIMENTO}
        ) a,
        dbamv.atendime b,
        dbamv.convenio c,
        dbamv.paciente p,
        dbamv.pro_fat pf,
        dbamv.tip_acom ta,
        dbamv.exa_rx rx,
        dbamv.exa_lab lb,
        dbamv.produto pr,
        dbamv.cirurgia cr,
        dbamv.item_res re
  WHERE a.cd_atendimento = b.cd_atendimento
    AND b.cd_paciente = p.cd_paciente
    AND a.cd_convenio = c.cd_convenio
    AND a.item_referencia = pf.cd_pro_fat (+)
    AND a.item_referencia = ta.cd_tip_acom (+)
    AND a.item_referencia = rx.cd_exa_rx (+)
    AND a.item_referencia = lb.cd_exa_lab (+)
    AND a.item_referencia = pr.cd_produto (+)
    AND a.item_referencia = cr.cd_cirurgia (+)
    AND a.item_referencia = re.cd_item_res (+)
    AND p.cd_paciente = {V_CD_PACIENTE}
    {V_CD_CONDICAO}
) ORDER BY cd_atendimento, tp_referencia, item_referencia, ds_unidade, qt_item
