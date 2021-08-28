# Exploring Covid-19

<hr>
<div>
  
## Introduction
  <p>

The Covid-19 pandemic has changed our lives in a way we have not been prepared for. Thinking about this, I decided to practice my SQL muscles exploring some data about the COVID-19 around the world using PostgreSQL and Tableau for visualization. In this project I will walk through an SQL data exploration, cleaning and visualization in Tableau. <br>
The dataset can be downloaded at [Our World in Data](https://ourworldindata.org/covid-deaths). <br>
I hope to exercise and improve my SQL skills. Feel free to give your feedback. This is a really basic project, so let's get into it, hope you enjoy!<br>
  </p>

</div>
<hr>

## The data 

This is a time series dataset, that contains daily updated of the worldwide number of new cases, total cases, new deaths, total deaths, new vaccinations, total vaccinations and more.
Bellow one can see a sample of the data set.

<p align="center">
<img width="480" height="320" src="images/deaths.jpeg">

<p align="center">
<img width="480" height="320" src="images/vaccines.jpeg">


The original file is a .csv containing all the information. For a better performance when querying, it was split into two separated tables, one with all the cases and deaths information and the
other containing the vaccinations and other information.

<div>

## The exploratory data analysis
  <p>
In this first part of the project will performed a simple exploratory data analysis on the data to discover some numbers about the COVID-19 pandemic in the World, and, specifically, in Brazil. <br>
Summarising, the following questions were answered: <br>
<ol>
<li>What are the total cases, deaths and the <i>lethallity rate</i> (percent of people who died after get infected by COVID-19) in the world?</li>
<li>Considering each of the continents, how many people have passed way until now (2021/07/21)?</li>
<li>Until now, how much is the <i>infection rate</i> (percent of population that has been infect by COVID-19) country-wise?</li>
<li>Considering <b>Brazil</b>, what looks likes the evolution of new cases and the percent of population vaccinated?</li>
</ol>
<br>

For the visualization, it was exported the above queries answers in .xmlx format to make a Dashboard using Tableau. Bellow you can see the static Dashboard image. For the interactive view of this Dashboard, please visit [my page](https://public.tableau.com/app/profile/michel.de.ara.jo/viz/COVID-19innumbers_16268902575460/Dashboard1?publish=yes) at Tableau Public. <br>

<p align="center">
<img width="480" height="320" src="images/eda_dashboard.png">



</p>

  </p>

</div>
<hr>
