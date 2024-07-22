--DADOS_ATENDIME
select distinct protocolo.ds_protocolo medicamento
      ,null codigo_atendimento 
      ,null HR_ATENDIMENTO
      ,paciente.cd_paciente codigo_paciente      
      ,paciente.nm_paciente nome_paciente
      ,agendamento_oncologico.DH_INICIO_AGENDAMENTO_ONC
      ,TO_CHAR(agendamento_oncologico.DH_INICIO_AGENDAMENTO_ONC,'DD/MM/YYYY hh:mi:ss') AS DT_HR_AGENDAMENTO
      ,convenio.nm_convenio      
      ,con_pla.ds_con_pla
      ,decode(agendamento_oncologico.TP_STATUS, 'A', 'Atendido'
                                      , 'C', 'Cancelado'
                                      , 'G', 'Agendado'
                                      , 'F', 'Faltou' ) as STATUS_AGENDAMENTO
      ,case
          when guias.tp_situacao = 'A' then 'Autorizada'
          when guias.tp_situacao = 'S' then 'Solicitada'    
          else 'Sem guia'
       end situacao_guia 
  from agendamento_oncologico   
       inner join dbamv.solic_agendamento on solic_agendamento.cd_solic_agendamento = agendamento_oncologico.cd_solic_agendamento 
       inner join dbamv.itpre_med on itpre_med.cd_itpre_med = solic_agendamento.cd_itpre_med 
       inner join dbamv.pre_med on pre_med.cd_pre_med = itpre_med.cd_pre_med  
       inner join dbamv.tratamento on tratamento.cd_tratamento = pre_med.cd_tratamento       
       inner join dbamv.protocolo on protocolo.cd_protocolo = tratamento.cd_protocolo                       
                                 and protocolo.cd_protocolo IN ({AUX_PROTO})
       inner join dbamv.paciente on paciente.cd_paciente = agendamento_oncologico.cd_paciente     
                                and paciente.tp_situacao = 'N'
       inner join dbamv.atendime on atendime.cd_atendimento = pre_med.cd_atendimento
       inner join dbamv.convenio on convenio.cd_convenio = atendime.cd_convenio
                                and convenio.cd_convenio IN ({AUX_CONV})
       left join dbamv.con_pla on con_pla.cd_con_pla = atendime.cd_con_pla                              
                              and con_pla.cd_convenio = convenio.cd_convenio      
       left join (select /*+rule*/ guia.cd_atendimento 
                        ,pre_med.cd_pre_med
                        ,pre_med.dt_referencia
                        ,it_guia.cd_pro_fat
                        ,tip_presc.ds_tip_presc
                        ,guia.tp_situacao
                    from dbamv.guia 
                         inner join dbamv.it_guia on it_guia.cd_guia = guia.cd_guia
                         inner join dbamv.pre_med on pre_med.cd_atendimento = guia.cd_atendimento
                         inner join dbamv.itpre_med on itpre_med.cd_pre_med = pre_med.cd_pre_med
                         inner join dbamv.tip_presc on tip_presc.cd_tip_presc = itpre_med.cd_tip_presc
                                                   and tip_presc.cd_tip_esq = 'MDO'                                                  
                         inner join dbamv.produto on produto.cd_produto = tip_presc.cd_produto
                                                 and produto.cd_pro_fat = it_guia.cd_pro_fat
                         inner join dbamv.tiss_sol_guia on tiss_sol_guia.cd_guia = guia.cd_guia   
                                                       and tiss_sol_guia.nr_ciclo_atual = '0'|| (pre_med.nr_ciclo)          
                   where guia.tp_guia = 'Q'                                                    
                 ) guias on guias.cd_atendimento = pre_med.cd_atendimento 
                        and guias.dt_referencia = pre_med.dt_referencia  
 where agendamento_oncologico.TP_STATUS <> 'A' 
   and agendamento_oncologico.TP_STATUS IN ({AUX_STAT})  
   and trunc(agendamento_oncologico.dh_inicio_agendamento_onc) BETWEEN (@P_DT_INI - 1) AND @P_DT_FIM
union all
select distinct protocolo.ds_protocolo medicamento
      ,atendime.cd_atendimento codigo_atendimento 
      ,to_char(atendime.dt_atendimento,'DD/MM/YYYY') || '-' || to_char(atendime.hr_atendimento,'HH24:mi:ss') as HR_ATENDIMENTO
      ,paciente.cd_paciente codigo_paciente
      ,paciente.nm_paciente nome_paciente
      ,agendamento_oncologico.DH_INICIO_AGENDAMENTO_ONC dt
      ,TO_CHAR(agendamento_oncologico.DH_INICIO_AGENDAMENTO_ONC,'DD/MM/YYYY hh:mi:ss') AS DT_HR_AGENDAMENTO      
      ,convenio.nm_convenio      
      ,con_pla.ds_con_pla
      ,decode(agendamento_oncologico.TP_STATUS, 'A', 'Atendido'
                                      , 'C', 'Cancelado'
                                      , 'G', 'Agendado'
                                      , 'F', 'Faltou' ) as STATUS_AGENDAMENTO
      ,case
          when guias.tp_situacao = 'A' then 'Autorizada'
          when guias.tp_situacao = 'S' then 'Solicitada'    
          else 'Sem guia'
       end situacao_guia 
  from agendamento_oncologico                
       inner join dbamv.pre_med on pre_med.cd_atendimento = agendamento_oncologico.cd_atendimento                               
                               and pre_med.cd_objeto = 681                              
       inner join dbamv.paciente on paciente.cd_paciente = agendamento_oncologico.cd_paciente  
                                and paciente.tp_situacao = 'N'     
       inner join dbamv.atendime on atendime.cd_atendimento = pre_med.cd_atendimento                                
                                and trunc(atendime.dt_atendimento) BETWEEN (@P_DT_INI -1) AND @P_DT_FIM 
       inner join dbamv.convenio on convenio.cd_convenio = atendime.cd_convenio
                                and convenio.cd_convenio IN ({AUX_CONV})
       inner join dbamv.con_pla on con_pla.cd_con_pla = atendime.cd_con_pla   
                               and con_pla.cd_convenio = convenio.cd_convenio                          
       inner join dbamv.tratamento on tratamento.cd_tratamento = pre_med.cd_tratamento       
       inner join dbamv.protocolo on protocolo.cd_protocolo = tratamento.cd_protocolo
                                 and protocolo.cd_protocolo IN ({AUX_PROTO})
       left join (select /*+rule*/ guia.cd_atendimento 
                        ,pre_med.cd_pre_med
                        ,pre_med.dt_referencia
                        ,it_guia.cd_pro_fat
                        ,tip_presc.ds_tip_presc
                        ,guia.tp_situacao
                    from dbamv.guia 
                         inner join dbamv.it_guia on it_guia.cd_guia = guia.cd_guia
                         inner join dbamv.pre_med on pre_med.cd_atendimento = guia.cd_atendimento
                         inner join dbamv.itpre_med on itpre_med.cd_pre_med = pre_med.cd_pre_med
                         inner join dbamv.tip_presc on tip_presc.cd_tip_presc = itpre_med.cd_tip_presc
                                                   and tip_presc.cd_tip_esq = 'MDO'                                                  
                         inner join dbamv.produto on produto.cd_produto = tip_presc.cd_produto
                                                 and produto.cd_pro_fat = it_guia.cd_pro_fat 
                         inner join dbamv.tiss_sol_guia on tiss_sol_guia.cd_guia = guia.cd_guia   
                                                       and tiss_sol_guia.nr_ciclo_atual = '0'|| (pre_med.nr_ciclo) 
                   where guia.tp_guia = 'Q'                                                    
                 ) guias on guias.cd_atendimento = pre_med.cd_atendimento 
                        and guias.dt_referencia = pre_med.dt_referencia  
 where agendamento_oncologico.TP_STATUS not in ('C','G','F')  
   and agendamento_oncologico.TP_STATUS IN ({AUX_STAT}) 
order by 6

------BASE DE DADOS PARA REPORT SEPARADAS----------

--LIST_CONVENIO
SELECT cd_convenio, nm_convenio FROM dbamv.convenio
ORDER BY 2 
--LIST_PROTOCOLO
SELECT cd_protocolo, ds_protocolo FROM dbamv.protocolo WHERE tp_contagem = 'I' and sn_ativo = 'S'
ORDER BY 2 