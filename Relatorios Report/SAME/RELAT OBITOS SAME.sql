SELECT DISTINCT
    s.nr_matricula_same,
    p.nm_paciente, 
    p.cd_paciente,
    a.dt_alta
FROM
    same s,
    atendime a,
    paciente p
WHERE  a.cd_paciente  = p.cd_paciente
    and s.cd_paciente = p.cd_paciente
    and sn_obito = 'S'
    and cd_mot_alt IS NOT NULL
    and TRUNC(dt_alta) BETWEEN TRUNC(@INICIAL) and TRUNC(@FINAL)
    order by a.dt_alta