-- ranking de vendas por tipo (forro)
SELECT
    Totais.vendedor AS Vendedor,
    SUM(Totais.Quantidade_Total) AS Quantidade_Vendida
FROM (
    -- Vendas
    SELECT
        emp.name AS vendedor,
        (pxaprd.qtty / 1000) AS Quantidade_Total,
        (pxaprd.qtty / 1000) * (pxaprd.sl_price / 100) AS Valor_Total
    FROM pxa
    LEFT JOIN emp ON pxa.empno = emp.no
    LEFT JOIN pxaprd ON pxa.storeno = pxaprd.storeno
                     AND pxa.pdvno = pxaprd.pdvno
                     AND pxa.xano = pxaprd.xano
    LEFT JOIN nf ON pxa.storeno = nf.storeno
                 AND pxa.pdvno = nf.pdvno
                 AND pxa.xano = nf.xano
    LEFT JOIN prd ON pxaprd.prdno = prd.no
    WHERE
        prd.typeno = 15
        AND pxa.date BETWEEN [DI] AND [DF]
        AND (pxa.bits & POW(2,7)) != POW(2,7)
        AND (pxa.bits & POW(2,4)) != POW(2,4)
        AND pxa.cfo NOT IN (5117, 6117, 5910, 6910)
        AND nf.tipo <> 3
        AND pxa.xatype NOT IN (10)
        AND pxa.amt > 0

    UNION ALL

    -- Devoluções
    SELECT
        emp.name AS vendedor,
        (xalog2.qtty / 1000) AS Quantidade_Total,
        (xalog2.qtty / 1000) * ABS(xalog2.price / 100) AS Valor_Total
    FROM xalog2
    LEFT JOIN emp ON xalog2.empno = emp.no
    LEFT JOIN prd ON xalog2.prdno = prd.no
    WHERE
        prd.typeno = 15
        AND xalog2.date BETWEEN [DI] AND [DF]
        AND xalog2.qtty < 0
        AND xalog2.xatype NOT IN (10)
        AND (
            xalog2.storeno = 27
            OR xalog2.storeno = 57
            OR xalog2.storeno NOT IN (27, 57)
        )
) AS Totais
GROUP BY Totais.vendedor
ORDER BY Quantidade_Vendida DESC
LIMIT 10;