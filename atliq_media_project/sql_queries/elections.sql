-- Top and bottom 5 constituencies by voter turnout ratio for the year 2014
-- Top 5 constituencies
SELECT TOP 5
    pc_name AS constituency
    ,ROUND(CAST(SUM(total_votes) AS FLOAT)/MAX(total_electors) * 100, 2) AS voter_turnout_ratio
FROM
    election_results
WHERE
    [Year] = 2014
GROUP BY
    pc_name
ORDER BY
    voter_turnout_ratio DESC
    ;
USE atliq_media;
-- Bottom 5 constituencies
SELECT TOP 5
    pc_name AS constituency
    ,ROUND(CAST(SUM(total_votes) AS FLOAT)/MAX(total_electors) * 100, 2) AS voter_turnout_ratio
FROM
    election_results
WHERE
    [Year] = 2014
GROUP BY
    pc_name
ORDER BY
    voter_turnout_ratio
    ;

-- Top and bottom 5 constituencies by voter turnout ratio for the year 2019
-- Top 5 constituencies
SELECT TOP 5
    pc_name AS constituency
    ,ROUND(CAST(SUM(total_votes) AS FLOAT)/MAX(total_electors) * 100, 2) AS voter_turnout_ratio
FROM
    election_results
WHERE
    [Year] = 2019
GROUP BY
    pc_name
ORDER BY
    voter_turnout_ratio DESC
    ;

-- Bottom 5 constituencies
SELECT TOP 5
    pc_name AS constituency
    ,ROUND(CAST(SUM(total_votes) AS FLOAT)/MAX(total_electors) * 100, 2) AS voter_turnout_ratio
FROM
    election_results
WHERE
    [Year] = 2019
GROUP BY
    pc_name
ORDER BY
    voter_turnout_ratio
    ;

-- Top and bottom 5 states by voter turnout ratio for the year 2014
-- Top 5 states
SELECT TOP 5
    [state] AS state
    ,ROUND(CAST(SUM(total_votes) AS FLOAT)/SUM(DISTINCT total_electors) * 100, 2) AS voter_turnout_ratio
FROM
    election_results
WHERE
    [Year] = 2014
GROUP BY
    [state]
ORDER BY
    voter_turnout_ratio DESC
    ;

-- Bottom 5 states
SELECT TOP 5
    [state] AS state
    ,ROUND(CAST(SUM(total_votes) AS FLOAT)/SUM(DISTINCT total_electors) * 100, 2) AS voter_turnout_ratio
FROM
    election_results
WHERE
    [Year] = 2014
GROUP BY
    [state]
ORDER BY
    voter_turnout_ratio
    ;

-- Top and bottom 5 states by voter turnout ratio for the year 2019
-- Top 5 states
SELECT TOP 5
    [state] AS state
    ,ROUND(CAST(SUM(total_votes) AS FLOAT)/SUM(DISTINCT total_electors) * 100, 2) AS voter_turnout_ratio
FROM
    election_results
WHERE
    [Year] = 2019
GROUP BY
    [state]
ORDER BY
    voter_turnout_ratio DESC
    ;

-- Bottom 5 states
SELECT TOP 5
    [state] AS state
    ,ROUND(CAST(SUM(total_votes) AS FLOAT)/SUM(DISTINCT total_electors) * 100, 2) AS voter_turnout_ratio
FROM
    election_results
WHERE
    [Year] = 2019
GROUP BY
    [state]
ORDER BY
    voter_turnout_ratio
    ;

/*
Which constituties have elected the same party for two consecutive elections,
rank them by % of votes to that winning party in 2019? 
*/

WITH winning_parties_14 AS (
        SELECT
            *
            ,DENSE_RANK() OVER(PARTITION BY pc_name ORDER BY total_votes DESC) AS winning_rank
        FROM
            election_results
        WHERE
            [Year] = 2014
    ),

     winning_parties_19 AS (
        SELECT
            *
            ,DENSE_RANK() OVER(PARTITION BY pc_name ORDER BY total_votes DESC) AS winning_rank
        FROM
            election_results
        WHERE
            [Year] = 2019
    ),

    total_votes_19 AS (
        SELECT
            pc_name AS constituency
            ,SUM(total_votes) AS total_votes
        FROM
            election_results
        WHERE
            [Year] = 2019
        GROUP BY
            pc_name
    )

SELECT
    wp19.pc_name
    ,wp14.party AS party_14
    ,wp19.party AS party_19
    ,ROUND((wp19.total_votes * 1.0 / CAST(tv19.total_votes AS float) ) * 100, 2) AS vote_share_19
FROM
    winning_parties_14 wp14
JOIN
    winning_parties_19 wp19 ON wp14.pc_name = wp19.pc_name
JOIN
    total_votes_19 tv19 ON wp19.pc_name = tv19.constituency
WHERE
    wp14.winning_rank = 1 AND wp19.winning_rank = 1 AND wp14.party = wp19.party
ORDER BY
    vote_share_19 DESC
    ;


/*
Which constituencies have voted for different parties in two elections (list
top 10 based on difference (2019-2014) in winner vote percentage in two
elections).
*/

WITH winning_parties_14 AS (
        SELECT
            *
            ,DENSE_RANK() OVER(PARTITION BY pc_name ORDER BY total_votes DESC) AS winning_rank
        FROM
            election_results
        WHERE
            [Year] = 2014
    ),

     winning_parties_19 AS (
        SELECT
            *
            ,DENSE_RANK() OVER(PARTITION BY pc_name ORDER BY total_votes DESC) AS winning_rank
        FROM
            election_results
        WHERE
            [Year] = 2019
    ),

    total_votes_14 AS (
        SELECT
            pc_name AS constituency
            ,SUM(total_votes) AS total_votes
        FROM
            election_results
        WHERE
            [Year] = 2014
        GROUP BY
            pc_name
    ),

    total_votes_19 AS (
        SELECT
            pc_name AS constituency
            ,SUM(total_votes) AS total_votes
        FROM
            election_results
        WHERE
            [Year] = 2019
        GROUP BY
            pc_name
    ),

    vote_shares AS (
        SELECT
            wp19.pc_name
            ,wp14.party AS party_14
            ,wp19.party AS party_19
            ,ROUND((wp14.total_votes * 1.0 / CAST(tv14.total_votes AS float) ) * 100, 2) AS vote_share_14
            ,ROUND((wp19.total_votes * 1.0 / CAST(tv19.total_votes AS float) ) * 100, 2) AS vote_share_19
        FROM
            winning_parties_14 wp14
        JOIN
            winning_parties_19 wp19 ON wp14.pc_name = wp19.pc_name
        JOIN
            total_votes_19 tv19 ON wp19.pc_name = tv19.constituency
        JOIN
            total_votes_14 tv14 ON wp14.pc_name = tv14.constituency
        WHERE
            wp14.winning_rank = 1 AND wp19.winning_rank = 1 AND wp14.party != wp19.party
        
    )

SELECT TOP 10
    pc_name
    ,party_14
    ,party_19
    ,ROUND(vote_share_19 - vote_share_14, 2) AS vote_share_diff
FROM
    vote_shares
ORDER BY
    vote_share_diff DESC
    ;


/*
Top 5 candidates based on margin difference with runners in 2014 and
2019.
*/
-- 2014
WITH all_winners_14 AS (
    SELECT
        *
        ,DENSE_RANK() OVER( PARTITION BY pc_name ORDER BY total_votes DESC) AS winning_rank
    FROM
        election_results
    WHERE
        [Year] = 2014
     ),

     winners AS (
        SELECT
            pc_name
            ,candidate
            ,total_votes
            ,winning_rank
        FROM
            all_winners_14
        WHERE
            winning_rank = 1
     ),

     runner_ups AS (
        SELECT
            pc_name
            ,candidate
            ,total_votes
            ,winning_rank
        FROM
            all_winners_14
        WHERE
            winning_rank = 2
     )

SELECT TOP 5
    w.pc_name
    ,w.candidate
    ,w.total_votes - ru.total_votes AS margin_difference
FROM
    winners w
JOIN
    runner_ups ru ON w.pc_name = ru.pc_name
ORDER BY
    margin_difference DESC
    ;


--2019
WITH all_winners_19 AS (
    SELECT
        *
        ,DENSE_RANK() OVER( PARTITION BY pc_name ORDER BY total_votes DESC) AS winning_rank
    FROM
        election_results
    WHERE
        [Year] = 2019
     ),

     winners AS (
        SELECT
            pc_name
            ,candidate
            ,total_votes
            ,winning_rank
        FROM
            all_winners_19
        WHERE
            winning_rank = 1
     ),

     runner_ups AS (
        SELECT
            pc_name
            ,candidate
            ,total_votes
            ,winning_rank
        FROM
            all_winners_19
        WHERE
            winning_rank = 2
     )

SELECT TOP 5
    w.pc_name
    ,w.candidate
    ,w.total_votes - ru.total_votes AS margin_difference
FROM
    winners w
JOIN
    runner_ups ru ON w.pc_name = ru.pc_name
ORDER BY
    margin_difference DESC
    ;


/*
% Split of votes of parties between 2014 vs 2019 at national level
*/
-- 2014
SELECT
    party
    ,ROUND((SUM(total_votes) * 1.0 /
     CAST((SELECT 
             SUM(total_votes)
           FROM 
             election_results
           WHERE 
             [Year] = 2014) AS FLOAT) * 100), 2) AS percent_split_of_votes
FROM
    election_results
WHERE
    [Year] = 2014
GROUP BY
    party
ORDER BY
    percent_split_of_votes DESC;

-- 2019
SELECT
    party
    ,ROUND((SUM(total_votes) * 1.0 /
     CAST((SELECT 
             SUM(total_votes)
           FROM 
             election_results
           WHERE 
             [Year] = 2014) AS FLOAT) * 100), 2) AS percent_split_of_votes
FROM
    election_results
WHERE
    [Year] = 2019
GROUP BY
    party
ORDER BY
    percent_split_of_votes DESC;


/*
% Split of votes of parties between 2014 vs 2019 at state level
*/
-- 2014
SELECT
    [state]
    ,party
    ,ROUND((SUM(total_votes) * 1.0 /
     CAST((SELECT 
             SUM(total_votes)
           FROM 
             election_results
           WHERE 
             [Year] = 2014) AS FLOAT) * 100), 2) AS percent_split_of_votes
FROM
    election_results
WHERE
    [Year] = 2014
GROUP BY
    [state],party
ORDER BY
    percent_split_of_votes DESC;

-- 2019
SELECT
    [state]
    ,party
    ,ROUND((SUM(total_votes) * 1.0 /
     CAST((SELECT 
             SUM(total_votes)
           FROM 
             election_results
           WHERE 
             [Year] = 2014) AS FLOAT) * 100), 2) AS percent_split_of_votes
FROM
    election_results
WHERE
    [Year] = 2019
GROUP BY
    [state],party
ORDER BY
    percent_split_of_votes DESC;

   
/*
List top 5 constituencies for two major national parties where they have
gained vote share in 2019 as compared to 2014.
*/

-- 1st major national party (BJP)
WITH total_votes_14 AS (
    SELECT
        pc_name
        ,party
        ,total_votes
        ,ROUND(total_votes * 1.0 / SUM(CAST(total_votes AS FLOAT)) OVER (PARTITION BY pc_name) * 100, 2) AS vote_share_14
    FROM
        election_results
    WHERE
        [Year] = 2014
),

total_votes_19 AS (
    SELECT
        pc_name
        ,party
        ,total_votes
        ,ROUND(total_votes * 1.0 / SUM(CAST(total_votes AS FLOAT)) OVER (PARTITION BY pc_name) * 100, 2) AS vote_share_19
    FROM
        election_results
    WHERE
        [Year] = 2019
)

SELECT TOP 5
    tv14.pc_name
    ,tv14.party
    ,ROUND((tv19.vote_share_19 - tv14.vote_share_14), 2) AS vote_share_gain
FROM
    total_votes_14 tv14
JOIN
    total_votes_19 tv19 
    ON tv14.pc_name = tv19.pc_name
    AND tv14.party = tv19.party
WHERE
    tv14.party = 'BJP'
ORDER BY
    vote_share_gain DESC;


-- 2nd major national party
WITH total_votes_14 AS (
    SELECT
        pc_name
        ,party
        ,total_votes
        ,ROUND(total_votes * 1.0 / SUM(CAST(total_votes AS FLOAT)) OVER (PARTITION BY pc_name) * 100, 2) AS vote_share_14
    FROM
        election_results
    WHERE
        [Year] = 2014
),

total_votes_19 AS (
    SELECT
        pc_name
        ,party
        ,total_votes
        ,ROUND(total_votes * 1.0 / SUM(CAST(total_votes AS FLOAT)) OVER (PARTITION BY pc_name) * 100, 2) AS vote_share_19
    FROM
        election_results
    WHERE
        [Year] = 2019
)

SELECT TOP 5
    tv14.pc_name
    ,tv14.party
    ,ROUND((tv19.vote_share_19 - tv14.vote_share_14), 2) AS vote_share_gain
FROM
    total_votes_14 tv14
JOIN
    total_votes_19 tv19 
    ON tv14.pc_name = tv19.pc_name
    AND tv14.party = tv19.party
WHERE
    tv14.party = 'INC'
ORDER BY
    vote_share_gain DESC;


  
/*
List top 5 constituencies for two major national parties where they have
lost vote share in 2019 as compared to 2014.
*/

-- 1st major national party (BJP)
WITH total_votes_14 AS (
    SELECT
        pc_name
        ,party
        ,total_votes
        ,ROUND(total_votes * 1.0 / SUM(CAST(total_votes AS FLOAT)) OVER (PARTITION BY pc_name) * 100, 2) AS vote_share_14
    FROM
        election_results
    WHERE
        [Year] = 2014
),

total_votes_19 AS (
    SELECT
        pc_name
        ,party
        ,total_votes
        ,ROUND(total_votes * 1.0 / SUM(CAST(total_votes AS FLOAT)) OVER (PARTITION BY pc_name) * 100, 2) AS vote_share_19
    FROM
        election_results
    WHERE
        [Year] = 2019
)

SELECT TOP 5
    tv14.pc_name
    ,tv14.party
    ,ROUND((tv14.vote_share_14 - tv19.vote_share_19), 2) AS lost_vote_share
FROM
    total_votes_14 tv14
JOIN
    total_votes_19 tv19 
    ON tv14.pc_name = tv19.pc_name
    AND tv14.party = tv19.party
WHERE
    tv14.party = 'BJP'
ORDER BY
    lost_vote_share DESC;


-- 2nd major national party
WITH total_votes_14 AS (
    SELECT
        pc_name
        ,party
        ,total_votes
        ,ROUND(total_votes * 1.0 / SUM(CAST(total_votes AS FLOAT)) OVER (PARTITION BY pc_name) * 100, 2) AS vote_share_14
    FROM
        election_results
    WHERE
        [Year] = 2014
),

total_votes_19 AS (
    SELECT
        pc_name
        ,party
        ,total_votes
        ,ROUND(total_votes * 1.0 / SUM(CAST(total_votes AS FLOAT)) OVER (PARTITION BY pc_name) * 100, 2) AS vote_share_19
    FROM
        election_results
    WHERE
        [Year] = 2019
)

SELECT TOP 5
    tv14.pc_name
    ,tv14.party
    ,ROUND((tv14.vote_share_14 - tv19.vote_share_19), 2) AS lost_vote_share
FROM
    total_votes_14 tv14
JOIN
    total_votes_19 tv19 
    ON tv14.pc_name = tv19.pc_name
    AND tv14.party = tv19.party
WHERE
    tv14.party = 'INC'
ORDER BY
    lost_vote_share DESC
    ;


-- Which constituency has voted the most for NOTA?
SELECT
    [year]
    ,constituency
    ,votes
FROM
    (
        SELECT
            pc_name AS constituency
            ,[Year]
            ,SUM(total_votes) AS votes
            ,ROW_NUMBER() OVER (PARTITION BY [Year] ORDER BY SUM(total_votes) DESC) AS nota_rank
        FROM
            election_results
        WHERE
            party = 'NOTA' AND [Year] IN (2014, 2019)
        GROUP BY
            pc_name, [Year]
    ) AS sub
WHERE
    nota_rank = 1
ORDER BY
    votes DESC
    ;


/*
Which constituencies have elected candidates whose party has less
than 10% vote share at state level in 2019?
*/
 
WITH votes_to_party AS (
    SELECT
        [state]
        ,party
        ,SUM(total_votes) AS votes
    FROM
        election_results
    WHERE
        [Year] = 2019
    GROUP BY
        [state],party
),

state_votes_count AS (
    SELECT
        [state]
        ,SUM(CAST(total_votes AS FLOAT)) AS votes
    FROM
        election_results
    WHERE
        [Year] = 2019
    GROUP BY
        [state]
),

vote_share AS (
    SELECT
        svc.[state]
        ,party
        ,ROUND((vtp.votes * 100.0) / svc.votes, 2) AS vote_share_19
    FROM
        state_votes_count svc
    JOIN
        votes_to_party vtp ON svc.[state] = vtp.[state]
),

winning_parties_19 AS (
    SELECT
        *
        ,DENSE_RANK() OVER(PARTITION BY pc_name ORDER BY total_votes DESC) AS winning_rank
    FROM
        election_results
    WHERE
        [Year] = 2019
)

SELECT
    vs.[state]
    ,wp19.pc_name
    ,vs.party
    ,vs.vote_share_19
FROM
    vote_share vs 
JOIN
    winning_parties_19 wp19 ON vs.[state] = wp19.[state] AND vs.party = wp19.party
WHERE
    vs.vote_share_19 < 10 AND
    wp19.winning_rank = 1
ORDER BY
    vs.vote_share_19 DESC
    ;