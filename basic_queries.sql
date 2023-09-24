# Analysis of movies released between 2012-1014 

-- source: unknown (provided by google during course completion)
--dataset: movies
--Queried using: BigQuery

------------------------------------------------------------------------------------------------------------------
##This is a simple project that answers general questions

SELECT *
FROM `chandra2-396108.movies.movie_data`

--------------------------------------------------------------------------------------------------------------------

--number of movies released by genre in this time period?

SELECT count(*) as number_of_movies,
      Genre
FROM `chandra2-396108.movies.movie_data`
GROUP BY Genre
ORDER BY Genre

------------------------------------------------------------------------------------------------------------------------
--Which genre has the most investment per movie and which generated the most revenue per movie?
--the budget and revenue are rounded to nearest cents

SELECT  ROUND(AVG(Budget_),2) as Budget_per_movie,
        ROUND(AVG(Revenue),2) as Revenue_per_movie,
        Genre
FROM `chandra2-396108.movies.movie_data`
GROUP BY Genre
ORDER BY Revenue_per_movie DESC 

----------------------------------------------------------------------------------------------------------------------------

--For visualization purpose, i have selected specific, required columns so that we can export the resulted table to make visulizations and analyse further in various tools like Tableau or R.

SELECT Movie_Title as movie_title,
      Release_Date as release_date,
      Genre as genre,
      Budget_ as budget,
      Revenue as revenue
FROM `chandra2-396108.movies.movie_data`

---------------------------------------------------------------------------------------------------------------
