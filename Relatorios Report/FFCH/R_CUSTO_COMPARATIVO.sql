------EMPRESA------------
SELECT DS_MULTI_EMPRESA FROM dbamv.multi_empresas WHERE CD_MULTI_EMPRESA = {V_CD_MULTI_EMPRESA}

------USUARIO------------
SELECT USER FROM DUAL

------------------FONTE-------------------------

SELECT c.cd_atendimento,
       c.ds_paciente,
       c.ds_convenio,
       c.dt_atendimento,
       c.dt_alta,
       c.cd_pro_fat,
       c.tp_referencia,
       c.item_referencia,
       c.ds_referencia,
       ds_unidade,
       c.qt_item_real,
       c.qt_item_padrao,
       Decode(c.cd_custo_ficha_item, NULL, c.cst_total, (c.qt_item_padrao * Nvl((
           SELECT AVG( NVL( fica.vl_unit_item, 0 )) vl_unit_item
	            FROM dbamv.fa_it_custo_atendimento fica
	          WHERE fica.cd_multi_empresa 								= dbamv.pkg_mv2000.le_empresa()
	            AND fica.dt_geracao_atendimento 							= c.dt_geracao_atendimento
	            AND NVL(fica.cd_setor_produziu, fica.cd_setor)			= c.cd_setor
	            AND DECODE(SUBSTR(fica.cd_origem, 1, 3), 'DIA', 'DIAR'
                                                        , 'PRO', 'PROC'
                                                        , 'TER', 'PROC'
                                                        , 'ERX', 'EXRX'
                                                        , 'ELB', 'EXLA'
                                                        , 'HON', 'SERV'
                                                        , 'TAX', 'CAPR'
                                                        , 'IMP', 'CAPR'
                                                        , 'SLC', 'CIRG'
                                                        , 'MAT', 'PROD'
                                                        , 'GAS', 'PROD' ) =  c.tp_referencia_item
		          AND SUBSTR(fica.cd_origem, 5, 99)  						= c.item_referencia
       ), 0))) vl_custo_real,  
       c.vl_custo_padrao,
       (c.vl_custo_padrao - Decode(c.cd_custo_ficha_item, NULL, cst_total, (c.qt_item_padrao * Nvl((
           SELECT AVG( NVL( fica.vl_unit_item, 0 )) vl_unit_item
	            FROM dbamv.fa_it_custo_atendimento fica
	          WHERE fica.cd_multi_empresa 								= dbamv.pkg_mv2000.le_empresa()
	            AND fica.dt_geracao_atendimento 							= c.dt_geracao_atendimento
	            AND NVL(fica.cd_setor_produziu, fica.cd_setor)			= c.cd_setor
	            AND DECODE(SUBSTR(fica.cd_origem, 1, 3), 'DIA', 'DIAR'
                                                        , 'PRO', 'PROC'
                                                        , 'TER', 'PROC'
                                                        , 'ERX', 'EXRX'
                                                        , 'ELB', 'EXLA'
                                                        , 'HON', 'SERV'
                                                        , 'TAX', 'CAPR'
                                                        , 'IMP', 'CAPR'
                                                        , 'SLC', 'CIRG'
                                                        , 'MAT', 'PROD'
                                                        , 'GAS', 'PROD' ) =  c.tp_referencia_item
		          AND SUBSTR(fica.cd_origem, 5, 99)  						= c.item_referencia
       ), 0))))vl_resultado
       
FROM ( 
    SELECT cd_atendimento,
          ds_paciente,
          ds_convenio,
          b.cd_pro_fat,
          b.dt_geracao_atendimento,
          ci2.cd_setor,
          b.cd_custo_ficha_item,
          ci2.tp_referencia tp_referencia_item,
          Nvl (Decode( ci2.tp_referencia, 'PROD', 'ITEM UTILIZADO',
                                          'SERV', 'SERVIÇO EXECUTADO', 
                                          'PROC', 'PROCEDIMENTO',
                                          'CABS', 'CUSTO ABSORVIDO',
                                          'CAPR', 'CUSTO APROPRIADO',
                                          'EXLA', 'EXAME LABORATORIAL',
                                          'EXRX', 'EXAME DE IMAGEM',
                                          'DIAR', 'DIARIA',
                                          'CIRG', 'CIRURGIA',
                                            NULL ), b.tp_referencia) tp_referencia,
          Nvl (Decode( ci2.tp_referencia, 'PROD', ci2.cd_produto,
                                          'SERV', ci2.cd_servico, 
                                          'PROC', ci2.cd_pro_fat,
                                          'CABS', ci2.cd_item_res,
                                          'CAPR', ci2.cd_setor_ref,
                                          'EXLA', ci2.cd_exa_lab,
                                          'EXRX', ci2.cd_exa_rx,
                                          'DIAR', ci2.cd_tip_acom,
                                          'CIRG', ci2.cd_cirurgia,
                                          NULL ), b.item_referencia) item_referencia, 
          Nvl (Decode( ci2.tp_referencia, 'PROD', pr2.ds_produto,
                                          'SERV', se2.ds_servico, 
                                          'PROC', pf2.ds_pro_fat,
                                          'CABS', re2.ds_item_res,
                                          'CAPR', st2.nm_setor,
                                          'EXLA', lb2.nm_exa_lab,
                                          'EXRX', rx2.ds_exa_rx,
                                          'DIAR', ta2.ds_tip_acom,
                                          'CIRG', cr2.ds_cirurgia,
                                          NULL), b.ds_referencia) ds_referencia, 
          Nvl(ci2.ds_unidade, b.ds_unidade) ds_unidade,
       
          Nvl(b.qt_item, 0)  qt_item_real,
          Nvl(b.qtde_padrao, 0) qt_item_padrao,
          Nvl(b.cst_total,0) cst_total,
          Nvl(b.vl_custo_padrao, 0) VL_CUSTO_PADRAO,

          dt_atendimento,
          dt_alta
      FROM (

            SELECT a.cd_atendimento,                                                                                            
                    p.cd_paciente||' - '||p.nm_paciente ds_paciente,
                    c.cd_convenio||' - '||c.nm_convenio ds_convenio,
                    a.cd_pro_fat,
                    a.dt_geracao_atendimento,
                    ci.cd_custo_ficha_item,
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
                    a.tp_item,
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
            
                    (SELECT Nvl(ci.qt_unidade, 0) QTDE_PADRAO 
                      FROM dbamv.custo_ficha cf1, dbamv.custo_ficha_item ci1 
                      WHERE cf1.cd_custo_ficha = ci.cd_custo_ficha
                        AND ci1.cd_custo_ficha_item = ci.cd_custo_ficha_item 
                        AND cf1.cd_pro_fat = a.cd_pro_fat
                    ) QTDE_PADRAO,

                    (SELECT (Nvl(ci.vl_custo_padrao, 0) * ci.qt_unidade) VL_CUSTO_PADRAO 
                      FROM dbamv.custo_ficha cf1, dbamv.custo_ficha_item ci1 
                      WHERE cf1.cd_custo_ficha = ci.cd_custo_ficha
                        AND ci1.cd_custo_ficha_item = ci.cd_custo_ficha_item 
                        AND cf1.cd_pro_fat = a.cd_pro_fat
                    ) VL_CUSTO_PADRAO,   
                                                                                
                    a.cst_unit,
                    a.cst_total,
                    To_Char(b.dt_atendimento, 'DD/MM/YYYY') dt_atendimento,
                    To_Char(b.dt_alta, 'DD/MM/YYYY') dt_alta

              FROM (SELECT cd_atendimento,
                            cd_convenio,
                            cd_pro_fat,                                                                                   
                            tp_item,
                            dt_geracao_atendimento,
                            SubStr(cd_origem,5,99) item_referencia,
                            cd_origem,                                                                                            
                            qt_item,
                            0 rec_unit,
                            0 rec_total,                                                                                      
                            Decode(tp_item,'REC', 0, vl_unit_item) cst_unit,
                            Decode(tp_item,'REC', 0, vl_total_item) cst_total
                      FROM dbamv.fa_it_custo_atendimento
                      WHERE tp_item <> 'REC'
                      AND cd_multi_empresa = {V_CD_MULTI_EMPRESA}                                                                                              
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
                  dbamv.item_res re,

                  dbamv.custo_ficha cf,
                  dbamv.custo_ficha_item ci

            WHERE a.cd_atendimento = b.cd_atendimento
              AND b.cd_paciente = p.cd_paciente
              AND a.cd_convenio = c.cd_convenio
              AND a.item_referencia = pf.cd_pro_fat     (+)
              AND a.item_referencia = ta.cd_tip_acom    (+)
              AND a.item_referencia = rx.cd_exa_rx      (+)
              AND a.item_referencia = lb.cd_exa_lab     (+)
              AND a.item_referencia = pr.cd_produto     (+)
              AND a.item_referencia = cr.cd_cirurgia    (+)
              AND a.item_referencia = re.cd_item_res    (+)

              AND a.cd_pro_fat = cf.cd_pro_fat          (+)
              AND cf.cd_custo_ficha = ci.cd_custo_ficha (+)
              AND p.cd_paciente = {V_CD_PACIENTE}
              {V_CD_CONDICAO}
          ) b,
          dbamv.custo_ficha_item ci2,
          dbamv.pro_fat pf2,
          dbamv.tip_acom ta2,
          dbamv.exa_rx rx2,
          dbamv.exa_lab lb2,
          dbamv.produto pr2,
          dbamv.cirurgia cr2,
          dbamv.item_res re2,
          dbamv.servico se2,
          dbamv.setor st2

    WHERE b.cd_custo_ficha_item = ci2.cd_custo_ficha_item (+)
      AND ci2.cd_pro_fat = pf2.cd_pro_fat                 (+)
      AND ci2.cd_tip_acom = ta2.cd_tip_acom               (+)
      AND ci2.cd_exa_rx  = rx2.cd_exa_rx                  (+)
      AND ci2.cd_exa_lab = lb2.cd_exa_lab                 (+)
      AND ci2.cd_produto = pr2.cd_produto                 (+)
      AND ci2.cd_cirurgia = cr2.cd_cirurgia               (+)
      AND ci2.cd_item_res = re2.cd_item_res               (+)
      AND ci2.cd_servico = se2.cd_servico                 (+)
      AND ci2.cd_setor_ref = st2.cd_setor                 (+)

) c  
ORDER BY c.cd_atendimento, c.dt_alta, c.tp_referencia, c.item_referencia