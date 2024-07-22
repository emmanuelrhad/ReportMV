SELECT distinct
    c.cd_convenio,
    p.cd_paciente,
    s.nr_matricula_same,
    p.nm_paciente,
    c.nm_convenio,
    p.nr_fone,
    ac.hr_inicio,
    pr.nm_prestador,
    pr.cd_prestador,
    se.nm_setor
FROM
    paciente          p,
    same              s,
    convenio          c,
    prestador         pr,
    agenda_central    ac,
    it_agenda_central iac,
    setor             se
WHERE  iac.cd_convenio = c.cd_convenio(+)
    AND p.cd_paciente = s.cd_paciente(+)
    AND p.cd_paciente = iac.cd_paciente
    AND ac.cd_setor   = se.cd_setor
    AND pr.cd_prestador = '{V_PRESTADOR}'
    AND ac.cd_agenda_central = iac.cd_agenda_central(+)
    AND ac.cd_prestador = pr.cd_prestador(+)
    and TRUNC(ac.hr_inicio) BETWEEN TRUNC(@INICIAL) AND TRUNC(@FINAL)
ORDER BY
    ac.hr_inicio