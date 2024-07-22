select distinct tip_presc.ds_tip_presc medicamento
      ,null codigo_atendimento 
      ,null as HR_ATENDIMENTO
      ,paciente.cd_paciente codigo_paciente
      ,paciente.nm_paciente nome_paciente
      ,pre_med.hr_pre_med
      ,to_char(pre_med.hr_pre_med,'dd/mm/yyyy') AS DT_HR_AGENDAMENTO      
      ,convenio.nm_convenio      
      ,con_pla.ds_con_pla
      ,'Planejado' as STATUS_AGENDAMENTO
  from dbamv.pre_med
       inner join dbamv.atendime  on atendime.cd_atendimento  = pre_med.cd_atendimento                                                              
       inner join dbamv.paciente on paciente.cd_paciente = atendime.cd_paciente
                                --and paciente.cd_paciente not in (1,2223,13197,13202,13145,13146,55881,93369,92398,94081)
       left join dbamv.convenio on convenio.cd_convenio = atendime.cd_convenio
       left join dbamv.con_pla on con_pla.cd_con_pla = atendime.cd_con_pla
                              and con_pla.cd_convenio = convenio.cd_convenio  
       inner join dbamv.itpre_med it on it.cd_pre_med = pre_med.cd_pre_med
                                 and it.cd_tip_esq = 'QMT'
                                 and it.tp_fase_qt = 'QT'
       left join dbamv.tip_presc on tip_presc.cd_tip_presc = it.cd_tip_presc
 where 
    pre_med.cd_objeto = 681
    and pre_med.sn_fechado = 'N'
    --and pre_med.dh_impressao is null
    and pre_med.dt_pre_med < (sysdate + 360)
    and trunc(pre_med.dt_pre_med) between @P_DT_INI and @P_DT_FIM
order by 6,5
