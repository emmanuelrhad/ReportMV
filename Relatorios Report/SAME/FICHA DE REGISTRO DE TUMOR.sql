SELECT distinct
    p.cd_paciente, 
    p.nm_paciente,
    p.nm_mae,
    p.nr_cpf,
    p.nr_cns,
    p.tp_sexo,
    P.dt_nascimento,
    p.nr_identidade,
    p.ds_om_identidade,
    p.ds_trabalho,
    p.ds_endereco || ' - ' || p.nr_endereco,
    p.nm_bairro,
    ci.nm_cidade,
    ci.cd_uf,
    ci.cd_ibge,
    p.nr_cep,
    s.nr_matricula_same,
    fn_idade(dbamv.p.dt_nascimento),
    a.cd_cid,
    po.nm_profissao,
    p.nr_fone,
    s.dt_cadastro
FROM
    dbamv.paciente  p,
    dbamv.same      s,
    dbamv.atendime  a,
    dbamv.prestador pr,
    dbamv.cidade    ci,
    dbamv.profissao po
WHERE
        s.cd_paciente         = p.cd_paciente
    AND a.cd_paciente         = p.cd_paciente
    AND p.cd_cidade(+)        = ci.cd_cidade
    AND s.nr_matricula_same   = substr('{V_SAME}',0,6)
    AND po.cd_profissao(+)    = p.cd_profissao
GROUP BY 
    p.cd_paciente, 
    p.nm_paciente,
    p.nm_mae,
    p.nr_cpf,
    p.nr_cns,
    p.tp_sexo,
    P.dt_nascimento,
    p.nr_identidade,
    p.ds_om_identidade,
    p.ds_trabalho,
    p.ds_endereco || ' - ' || p.nr_endereco,
    p.nm_bairro,
    ci.nm_cidade,
    ci.cd_uf,
    ci.cd_ibge,
    p.nr_cep,
    s.nr_matricula_same,
    fn_idade(dbamv.p.dt_nascimento),
    a.cd_cid,
    po.nm_profissao,
    p.nr_fone,
    s.dt_cadastro