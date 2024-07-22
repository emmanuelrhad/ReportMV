SELECT /*+rule*/ distinct pre_med.cd_atendimento, pre_med.cd_pre_med, convenio.nm_convenio, pre_med.dt_pre_med,
         paciente.cd_paciente, paciente.nm_paciente, to_char(paciente.dt_nascimento,'dd/mm/yyyy') dt_nascimento, itpre_med.cd_itpre_med,
         --solsai_pro.cd_solsai_pro,
         tip_presc.ds_tip_presc item_principal,
         itpre_med.qt_itpre_med   
         --itpre_med.qt_itpre_med * uni_pro.vl_fator
         || ' '
         || uni_pro.cd_unidade ds_unidade_principal,        
         --|| uni_pro.ds_unidade ds_unidade_principal,
         case
            when comp.cd_tip_esq is not null then
         '|--> ' || comp.ds_tip_presc
         end ds_tip_presc_item,       
         case
            when comp.cd_tip_esq is not null then 
            comp.qt_componente * uni_pro_item.vl_fator
         || ' '
         || uni_pro_item.cd_unidade
         --|| uni_pro_item.ds_unidade
         end  ds_unidade_item,
         produto_estabilidade.vl_tempo_validade || ' ' ||produto_estabilidade.tp_tempo_validade estabilidade,
         decode(produto_estabilidade.nr_tempo_infusao,null,null,produto_estabilidade.nr_tempo_infusao || ' ' || produto_estabilidade.tp_tempo_infusao) tempo_infusao,
         case
            when uni_pro_item.cd_unidade = 'ML' then comp.qt_componente * uni_pro_item.vl_fator 
            when prod_item.cd_dcb is not null and prod_item.cd_sican is not null then round(((comp.qt_componente * to_number(prod_item.cd_dcb, '9G999D99')) / to_number(prod_item.cd_sican, '9G999D99')),2)            
            else 0
         end vl_comp,
         itpre_med.ds_itpre_med observacao,
         for_apl.cd_for_apl || '-' || for_apl.ds_for_apl via,
         protocolo.ds_protocolo, 
         prestador.nm_prestador, hritpre_med.nr_dia,
         pre_med.nr_ciclo || ' / D' || nr_sessao AS ciclo,
         case
            when uni_pro.cd_unidade = 'ML' then itpre_med.qt_itpre_med * uni_pro.vl_fator 
            when produto.cd_dcb is not null and produto.cd_sican is not null then round(((itpre_med.qt_itpre_med * to_number(produto.cd_dcb, '9G999D99')) / to_number(produto.cd_sican, '999999.99')),2) 
            else 0
         end vl_total, 
         itpre_med.nr_ordem  
    FROM dbamv.pre_med
         inner join dbamv.itpre_med on itpre_med.cd_pre_med = pre_med.cd_pre_med
                                   and ((itpre_med.sn_cancelado <> 'S') OR (itpre_med.sn_cancelado IS NULL))
                                   --AND ITPRE_MED.CD_ITPRE_PAD IS NOT NULL
         inner join dbamv.atendime on atendime.cd_atendimento = pre_med.cd_atendimento
         inner join dbamv.for_apl on for_apl.cd_for_apl = itpre_med.cd_for_apl
         inner join dbamv.paciente on paciente.cd_paciente  = atendime.cd_paciente
         inner join dbamv.tip_presc on tip_presc.cd_tip_presc = itpre_med.cd_tip_presc   
                                   AND tip_presc.cd_tip_esq IN ('QMT', 'MED', 'SOR')      
         inner join dbamv.prestador on prestador.cd_prestador = pre_med.cd_prestador
                                   --and prestador.cd_tip_presta = 8  
         left join dbamv.citpre_med on citpre_med.cd_itpre_med = itpre_med.cd_itpre_med
                                   and citpre_med.tp_componente = 'M'
         left join (select citpre_med.cd_itpre_med
                          ,citpre_med.cd_tip_presc 
                          ,citpre_med.cd_uni_pro
                          ,citpre_med.qt_componente
                          ,citpre_med.cd_produto
                          ,itpre_pad.cd_pre_pad 
                          ,tip_presc_2.ds_tip_presc
                          ,tip_presc_2.cd_tip_esq                       
                      from (SELECT *   
                              FROM dbamv.tip_presc 
                             WHERE cd_tip_esq IN ('QMT', 'MED','PQT', 'SOR')) tip_presc_2 
                           left join dbamv.citpre_med on citpre_med.cd_tip_presc = tip_presc_2.cd_tip_presc
                                                     and citpre_med.tp_componente = 'M'  --and CD_PRE_MED = 3150
                           left join dbamv.itpre_pad on itpre_pad.cd_itpre_pad = citpre_med.cd_itpre_med            
                    ) comp on comp.cd_itpre_med = itpre_med.cd_itpre_med  
         left join dbamv.produto prod_item on prod_item.cd_produto = comp.cd_produto        
         left join dbamv.itpre_pad on itpre_pad.cd_itpre_pad = itpre_med.cd_itpre_pad
         left join dbamv.pre_pad on pre_pad.cd_pre_pad  = itpre_pad.cd_pre_pad
         left join dbamv.ciclo_trtm_protocolo_prepad on ciclo_trtm_protocolo_prepad.cd_pre_pad = itpre_pad.cd_pre_pad
         left join dbamv.ciclo_tratamento_protocolo on ciclo_tratamento_protocolo.cd_ciclo_tratamento_protocolo = ciclo_trtm_protocolo_prepad.cd_ciclo_tratamento_protocolo
         left join dbamv.protocolo on protocolo.cd_protocolo = ciclo_tratamento_protocolo.cd_protocolo
         inner join dbamv.hritpre_med on hritpre_med.cd_itpre_med = itpre_med.cd_itpre_med
                                    --AND HRITPRTIP_ESQ E_MED.NR_DIA = 1
         inner join dbamv.uni_pro on uni_pro.cd_uni_pro = itpre_med.cd_uni_pro         
         left join (SELECT *
                      FROM dbamv.uni_pro) uni_pro_item on uni_pro_item.cd_uni_pro = comp.cd_uni_pro
         left join dbamv.solsai_pro on solsai_pro.cd_pre_med = pre_med.cd_pre_med
         left join dbamv.produto on produto.cd_produto = tip_presc.cd_produto    
         left join dbamv.produto_estabilidade on produto_estabilidade.cd_produto = produto.cd_produto
         inner join dbamv.convenio on convenio.cd_convenio = atendime.cd_convenio                                          
   where 
   pre_med.cd_objeto = 681 
   AND PRE_MED.CD_PRE_MED = {cd_prescricao} --3150 --2694631
    --AND PRE_MED.DT_PRE_MED >= '05/11/2011'
UNION ALL  -- PROVINIENTE DA AVALIÇÃO FARMACÊUTICA
SELECT /*+rule*/ distinct pre_med.cd_atendimento, pre_med.cd_pre_med, convenio.nm_convenio, pre_med.dt_pre_med,
         paciente.cd_paciente, paciente.nm_paciente, to_char(paciente.dt_nascimento,'dd/mm/yyyy') dt_nascimento, novo.cd_itpre_med,
         --solsai_pro.cd_solsai_pro,
         tip_presc.ds_tip_presc item_principal,
         novo.qt_itpre_med
         --novo.qt_itpre_med * uni_pro.vl_fator
         || ' '
         || uni_pro.cd_unidade ds_unidade_principal,        
         --|| uni_pro.ds_unidade ds_unidade_principal,
       
         case
            when comp.cd_tip_esq is not null then
         '|--> ' || comp.ds_tip_presc
         end ds_tip_presc_item,       
         case
            when comp.cd_tip_esq is not null then 
            comp.qt_componente * uni_pro_item.vl_fator
         || ' '
         || uni_pro_item.cd_unidade
         --|| uni_pro_item.ds_unidade
         end  ds_unidade_item,
         produto_estabilidade.vl_tempo_validade || ' ' ||produto_estabilidade.tp_tempo_validade estabilidade,
         decode(produto_estabilidade.nr_tempo_infusao,null,null,produto_estabilidade.nr_tempo_infusao || ' ' || produto_estabilidade.tp_tempo_infusao) tempo_infusao,
         case
            when uni_pro_item.cd_unidade = 'ML' then comp.qt_componente * uni_pro_item.vl_fator 
            when prod_item.cd_dcb is not null and prod_item.cd_sican is not null then round(((comp.qt_componente * to_number(prod_item.cd_dcb, '9G999D99')) / to_number(prod_item.cd_sican, '9G999D99')),2)            
            else 0
         end vl_comp,
         novo.ds_itpre_med observacao,
         for_apl.cd_for_apl || '-' || for_apl.ds_for_apl via,
         protocolo.ds_protocolo, 
         prestador.nm_prestador, hritpre_med.nr_dia,
         pre_med.nr_ciclo || ' / D' || nr_sessao AS ciclo,
         case
            when uni_pro.cd_unidade = 'ML' then itpre_med.qt_itpre_med * uni_pro.vl_fator
            when produto.cd_dcb is not null and produto.cd_sican is not null then round(((novo.qt_itpre_med * to_number(produto.cd_dcb, '9G999D99')) / to_number(produto.cd_sican, '999999.99')),2)
            else 0             
         end vl_total, 
         novo.nr_ordem   
    FROM dbamv.pre_med
         inner join dbamv.itpre_med on itpre_med.cd_pre_med = pre_med.cd_pre_med
                                   and ((itpre_med.sn_cancelado = 'S') OR (itpre_med.sn_cancelado IS NOT NULL))
                                   and itpre_med.cd_prest_canc in (select cd_prestador
                                                                  from dbamv.prestador
                                                                 where prestador.cd_tip_presta = 32
                                                                 )
         inner join dbamv.itpre_med novo on novo.cd_itpre_med_copia = itpre_med.cd_itpre_med 
                                        and ((novo.sn_cancelado <> 'S') OR (novo.sn_cancelado IS NULL))       
                                        and novo.cd_pre_med <> itpre_med.cd_pre_med        
         inner join dbamv.atendime on atendime.cd_atendimento = pre_med.cd_atendimento
         inner join dbamv.for_apl on for_apl.cd_for_apl = novo.cd_for_apl
         inner join dbamv.paciente on paciente.cd_paciente  = atendime.cd_paciente
         inner join dbamv.tip_presc on tip_presc.cd_tip_presc = novo.cd_tip_presc   
                                   AND tip_presc.cd_tip_esq IN ('QMT', 'MED', 'SOR')      
         inner join dbamv.prestador on prestador.cd_prestador = pre_med.cd_prestador
                                   --and prestador.cd_tip_presta = 8
         left join dbamv.citpre_med on citpre_med.cd_itpre_med = novo.cd_itpre_med
                                   and citpre_med.tp_componente = 'M'
         left join (select citpre_med.cd_itpre_med
                          ,citpre_med.cd_tip_presc 
                          ,citpre_med.cd_uni_pro
                          ,citpre_med.qt_componente
                          ,citpre_med.cd_produto
                          ,itpre_pad.cd_pre_pad 
                          ,tip_presc_2.ds_tip_presc
                          ,tip_presc_2.cd_tip_esq                       
                      from (SELECT *   
                              FROM dbamv.tip_presc 
                             WHERE cd_tip_esq IN ('MED', 'QMT','PQT','SOR')) tip_presc_2 
                           left join dbamv.citpre_med on citpre_med.cd_tip_presc = tip_presc_2.cd_tip_presc
                                                     and citpre_med.tp_componente = 'M'  --and CD_PRE_MED = 3150
                           left join dbamv.itpre_pad on itpre_pad.cd_itpre_pad = citpre_med.cd_itpre_med            
                    ) comp on comp.cd_itpre_med = novo.cd_itpre_med  
         left join dbamv.produto prod_item on prod_item.cd_produto = comp.cd_produto        
         left join dbamv.itpre_pad on itpre_pad.cd_itpre_pad = novo.cd_itpre_pad
         left join dbamv.pre_pad on pre_pad.cd_pre_pad  = itpre_pad.cd_pre_pad
         left join dbamv.ciclo_trtm_protocolo_prepad on ciclo_trtm_protocolo_prepad.cd_pre_pad = itpre_pad.cd_pre_pad
         left join dbamv.ciclo_tratamento_protocolo on ciclo_tratamento_protocolo.cd_ciclo_tratamento_protocolo = ciclo_trtm_protocolo_prepad.cd_ciclo_tratamento_protocolo
         left join dbamv.protocolo on protocolo.cd_protocolo = ciclo_tratamento_protocolo.cd_protocolo
         inner join dbamv.hritpre_med on hritpre_med.cd_itpre_med = novo.cd_itpre_med
                                    --AND HRITPRTIP_ESQ E_MED.NR_DIA = 1
         inner join dbamv.uni_pro on uni_pro.cd_uni_pro = novo.cd_uni_pro         
         left join (SELECT *
                      FROM dbamv.uni_pro) uni_pro_item on uni_pro_item.cd_uni_pro = comp.cd_uni_pro
         left join dbamv.solsai_pro on solsai_pro.cd_pre_med = pre_med.cd_pre_med
         left join dbamv.produto on produto.cd_produto = tip_presc.cd_produto  
         left join dbamv.produto_estabilidade on produto_estabilidade.cd_produto = produto.cd_produto
         inner join dbamv.convenio on convenio.cd_convenio = atendime.cd_convenio                                            
   where 
   pre_med.cd_objeto = 681 
   AND PRE_MED.CD_PRE_MED = {cd_prescricao} --3150 --2694631
    --AND PRE_MED.DT_PRE_MED >= '05/11/2011' 
UNION ALL  -- PROVINIENTE DA AVALIÇÃO FARMACÊUTICA ** PRODUTO NOVO
SELECT /*+rule*/ distinct pre_med.cd_atendimento, pre_med.cd_pre_med, convenio.nm_convenio, pre_med.dt_pre_med,
         paciente.cd_paciente, paciente.nm_paciente, to_char(paciente.dt_nascimento,'dd/mm/yyyy') dt_nascimento,
         novo.cd_itpre_med,
         --solsai_pro.cd_solsai_pro,
         tip_presc.ds_tip_presc item_principal,
         novo.qt_itpre_med
         --novo.qt_itpre_med * uni_pro.vl_fator
         || ' '
         || uni_pro.cd_unidade ds_unidade_principal,        
         --|| uni_pro.ds_unidade ds_unidade_principal,
         case
            when comp.cd_tip_esq is not null then
         '|--> ' || comp.ds_tip_presc
         end ds_tip_presc_item,       
         case
            when comp.cd_tip_esq is not null then 
            comp.qt_componente * uni_pro_item.vl_fator
         || ' '
         || uni_pro_item.cd_unidade
         --|| uni_pro_item.ds_unidade
         end  ds_unidade_item,
         produto_estabilidade.vl_tempo_validade || ' ' ||produto_estabilidade.tp_tempo_validade estabilidade,
         decode(produto_estabilidade.nr_tempo_infusao,null,null,produto_estabilidade.nr_tempo_infusao || ' ' || produto_estabilidade.tp_tempo_infusao) tempo_infusao,
         case
            when uni_pro_item.cd_unidade = 'ML' then comp.qt_componente * uni_pro_item.vl_fator 
            when prod_item.cd_dcb is not null and prod_item.cd_sican is not null then round(((comp.qt_componente * to_number(prod_item.cd_dcb, '9G999D99')) / to_number(prod_item.cd_sican, '9G999D99')),2)            
            else 0
         end vl_comp,
         novo.ds_itpre_med observacao,
         for_apl.cd_for_apl || '-' || for_apl.ds_for_apl via,
         protocolo.ds_protocolo, 
         prestador.nm_prestador, hritpre_med.nr_dia,
         pre_med.nr_ciclo || ' / D' || nr_sessao AS ciclo,   
         case
            when uni_pro.cd_unidade = 'ML' then itpre_med.qt_itpre_med * uni_pro.vl_fator
            when produto.cd_dcb is not null and produto.cd_sican is not null then round(((novo.qt_itpre_med * to_number(produto.cd_dcb, '9G999D99')) / to_number(produto.cd_sican, '999999.99')),2)
            else 0 
         end vl_total,        
         novo.nr_ordem  
    FROM dbamv.pre_med
         inner join dbamv.itpre_med on itpre_med.cd_pre_med = pre_med.cd_pre_med
                                   and ((itpre_med.sn_cancelado = 'S') OR (itpre_med.sn_cancelado IS NOT NULL))
                                   and itpre_med.cd_prest_canc in (select cd_prestador
                                                                  from dbamv.prestador
                                                                 where prestador.cd_tip_presta = 32)                                                                 
         inner join dbamv.itpre_med susp on susp.cd_itpre_med_canc = itpre_med.cd_itpre_med 
                                        and ((susp.sn_cancelado = 'S') OR (susp.sn_cancelado IS NOT NULL))       
                                        and susp.cd_pre_med <> itpre_med.cd_pre_med  
         inner join dbamv.itpre_med novo on novo.cd_pre_med = susp.cd_pre_med 
                                        and ((novo.sn_cancelado <> 'S') OR (novo.sn_cancelado IS NULL))                                         
                                        and novo.sn_horario_gerado = 'S'     
                                        and novo.cd_tip_presc <> susp.cd_tip_presc 
                                        --and novo.cd_produto <> itpre_med.cd_produto
                                        and novo.cd_itpre_med_copia is null                                                                               
         inner join dbamv.atendime on atendime.cd_atendimento = pre_med.cd_atendimento
         inner join dbamv.for_apl on for_apl.cd_for_apl = novo.cd_for_apl
         inner join dbamv.paciente on paciente.cd_paciente  = atendime.cd_paciente
         inner join dbamv.tip_presc on tip_presc.cd_tip_presc = novo.cd_tip_presc   
                                   AND tip_presc.cd_tip_esq IN ('MED', 'QMT','PQT', 'SOR')      
         inner join dbamv.prestador on prestador.cd_prestador = pre_med.cd_prestador
                                   --and prestador.cd_tip_presta = 8
         left join dbamv.citpre_med on citpre_med.cd_itpre_med = novo.cd_itpre_med
                                   and citpre_med.tp_componente = 'M'
         left join (select citpre_med.cd_itpre_med
                          ,citpre_med.cd_tip_presc 
                          ,citpre_med.cd_uni_pro
                          ,citpre_med.qt_componente
                          ,citpre_med.cd_produto
                          ,itpre_pad.cd_pre_pad 
                          ,tip_presc_2.ds_tip_presc
                          ,tip_presc_2.cd_tip_esq                       
                      from (SELECT *   
                              FROM dbamv.tip_presc 
                             WHERE cd_tip_esq IN ('MNF', 'MDO', 'SOR','MDN')) tip_presc_2 
                           left join dbamv.citpre_med on citpre_med.cd_tip_presc = tip_presc_2.cd_tip_presc
                                                     --and citpre_med.tp_componente = 'M'  --and CD_PRE_MED = 3150
                           left join dbamv.itpre_pad on itpre_pad.cd_itpre_pad = citpre_med.cd_itpre_med            
                    ) comp on comp.cd_itpre_med = novo.cd_itpre_med  
         left join dbamv.produto prod_item on prod_item.cd_produto = comp.cd_produto        
         left join dbamv.itpre_pad on itpre_pad.cd_itpre_pad = itpre_med.cd_itpre_pad
         left join dbamv.pre_pad on pre_pad.cd_pre_pad  = itpre_pad.cd_pre_pad
         left join dbamv.ciclo_trtm_protocolo_prepad on ciclo_trtm_protocolo_prepad.cd_pre_pad = itpre_pad.cd_pre_pad
         left join dbamv.ciclo_tratamento_protocolo on ciclo_tratamento_protocolo.cd_ciclo_tratamento_protocolo = ciclo_trtm_protocolo_prepad.cd_ciclo_tratamento_protocolo
         left join dbamv.protocolo on protocolo.cd_protocolo = ciclo_tratamento_protocolo.cd_protocolo
         inner join dbamv.hritpre_med on hritpre_med.cd_itpre_med = novo.cd_itpre_med
                                    --AND HRITPRTIP_ESQ E_MED.NR_DIA = 1
         inner join dbamv.uni_pro on uni_pro.cd_uni_pro = novo.cd_uni_pro         
         left join (SELECT *
                      FROM dbamv.uni_pro) uni_pro_item on uni_pro_item.cd_uni_pro = comp.cd_uni_pro
         left join dbamv.solsai_pro on solsai_pro.cd_pre_med = pre_med.cd_pre_med
         left join dbamv.produto on produto.cd_produto = tip_presc.cd_produto 
         left join dbamv.produto_estabilidade on produto_estabilidade.cd_produto = produto.cd_produto  
         inner join dbamv.convenio on convenio.cd_convenio = atendime.cd_convenio                                           
   where 
   pre_med.cd_objeto = 681 
   AND PRE_MED.CD_PRE_MED = {cd_prescricao}  
ORDER BY nr_ordem