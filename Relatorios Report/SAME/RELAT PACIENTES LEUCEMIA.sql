select distinct
    p.cd_paciente,
    p.nm_paciente,
    s.nr_matricula_same
  from paciente p, same s, apac a
 
where cd_cid_principal like 'C9%'
   and p.cd_paciente = s.cd_paciente(+)
   and p.cd_paciente = a.cd_paciente
   and TRUNC(s.dt_cadastro) BETWEEN TRUNC(@INICIAL) and TRUNC(@FINAL)