select distinct dbamv.s.nr_matricula_same,
                dbamv.s.cd_paciente,
                dbamv.p.nm_paciente,
                dbamv.s.dt_cadastro dt_same

  from dbamv.same s,
   dbamv.paciente p,
    dbamv.atendime a,
     dbamv.it_same i
 where dbamv.s.nr_matricula_same >= 107001
   and dbamv.p.cd_paciente = dbamv.s.cd_paciente
   and dbamv.i.nr_matricula_same = dbamv.s.nr_matricula_same
   and dbamv.a.cd_atendimento = dbamv.i.cd_atendimento
   and TRUNC(s.dt_cadastro) BETWEEN TRUNC(@INICIAL) AND TRUNC(@FINAL)
 order by dbamv.s.nr_matricula_same, dbamv.s.dt_cadastro