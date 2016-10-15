Prediction intervals for ensemble time series forecasts
========================================================
author: Peter Ellis
date: December 2016
autosize: true




Ensemble time series work better than individual models
========================================================

- Bates and Granger (1969) [The Combination of Forecasts](https://www.jstor.org/stable/3008764?seq=1#page_scan_tab_contents)
- Many confirmations since.

## For example:
<!-- html table generated in R 3.3.1 by xtable 1.8-2 package -->
<!-- Sat Oct 15 14:44:44 2016 -->
<table border=1>
<tr> <th> model </th> <th> two </th> <th> four </th> <th> six </th> <th> eight </th>  </tr>
  <tr> <td> Theta </td> <td align="right"> 0.77 </td> <td align="right"> 1.06 </td> <td align="right"> 1.35 </td> <td align="right"> 1.62 </td> </tr>
  <tr> <td> ARIMA-ETS average </td> <td align="right"> 0.72 </td> <td align="right"> 1.07 </td> <td align="right"> 1.38 </td> <td align="right"> 1.75 </td> </tr>
  <tr> <td> ARIMA </td> <td align="right"> 0.75 </td> <td align="right"> 1.12 </td> <td align="right"> 1.43 </td> <td align="right"> 1.79 </td> </tr>
  <tr> <td> ETS </td> <td align="right"> 0.75 </td> <td align="right"> 1.11 </td> <td align="right"> 1.44 </td> <td align="right"> 1.82 </td> </tr>
  <tr> <td> Naive </td> <td align="right"> 1.08 </td> <td align="right"> 1.11 </td> <td align="right"> 1.74 </td> <td align="right"> 1.87 </td> </tr>
   </table>
*Mean absolute scaled error of forecasts for 756 quarterly series from the M3 competition, forecast horizon ranging from two to eight quarters.*


How to estimate prediction intervals?
========================
- Usually presumed some kind of weighted average of the components
- Weights might be estimated based on in-sample errors

But the components have poor coverage
===========================

For example from the M1 competition:

![m1-nohybrid](images/m1-results-nohybrid.svg)

Standard estimates for prediction intervals are conditional on the model being correct, despite the obvious randomness in model selection.

A conservative alternative
===================

- Take the extremes of the combined prediction interval coverage of the components of the ensemble

> "Those prediction intervals look dodgy because they are way too conservative. The package is taking the widest possible intervals that includes all the intervals produced by the individual models. So you only need one bad model, and the prediction intervals are screwed."


Definitely too wide...
============

![dodgy](images/p_dodgy.svg)

This particular example is a combination of five forecast methods

Let's test against a larger set of data
============

Data from forecasting competitions
========================
transition: none
### M1
<!-- html table generated in R 3.3.1 by xtable 1.8-2 package -->
<!-- Sat Oct 15 14:44:45 2016 -->
<table border=1>
<tr> <th>  </th> <th> Period </th> <th> DEMOGR </th> <th> INDUST </th> <th> INDUSTRIAL </th> <th> MACRO1 </th> <th> MACRO2 </th> <th> MICRO1 </th> <th> MICRO2 </th> <th> MICRO3 </th>  </tr>
  <tr> <td align="right"> 1 </td> <td> MONTHLY </td> <td align="right"> 75 </td> <td align="right"> 183 </td> <td align="right"> 0 </td> <td align="right"> 64 </td> <td align="right"> 92 </td> <td align="right"> 10 </td> <td align="right"> 89 </td> <td align="right"> 104 </td> </tr>
  <tr> <td align="right"> 2 </td> <td> QUARTERLY </td> <td align="right"> 39 </td> <td align="right"> 17 </td> <td align="right"> 1 </td> <td align="right"> 45 </td> <td align="right"> 59 </td> <td align="right"> 5 </td> <td align="right"> 21 </td> <td align="right"> 16 </td> </tr>
  <tr> <td align="right"> 3 </td> <td> YEARLY </td> <td align="right"> 30 </td> <td align="right"> 35 </td> <td align="right"> 0 </td> <td align="right"> 30 </td> <td align="right"> 29 </td> <td align="right"> 16 </td> <td align="right"> 29 </td> <td align="right"> 12 </td> </tr>
   </table>
Makridakis et al, 1982

Data from forecasting competitions
============
transition: none
### M3
<!-- html table generated in R 3.3.1 by xtable 1.8-2 package -->
<!-- Sat Oct 15 14:44:45 2016 -->
<table border=1>
<tr> <th>  </th> <th> Period </th> <th> DEMOGRAPHI- </th> <th> DEMOGRAPHIC </th> <th> FINANCE </th> <th> INDUSTRY </th> <th> MACRO </th> <th> MICRO </th> <th> OTHER </th>  </tr>
  <tr> <td align="right"> 1 </td> <td> MONTHLY </td> <td align="right"> 0 </td> <td align="right"> 111 </td> <td align="right"> 145 </td> <td align="right"> 334 </td> <td align="right"> 312 </td> <td align="right"> 474 </td> <td align="right"> 52 </td> </tr>
  <tr> <td align="right"> 2 </td> <td> OTHER </td> <td align="right"> 0 </td> <td align="right"> 0 </td> <td align="right"> 29 </td> <td align="right"> 0 </td> <td align="right"> 0 </td> <td align="right"> 4 </td> <td align="right"> 141 </td> </tr>
  <tr> <td align="right"> 3 </td> <td> QUARTERLY </td> <td align="right"> 57 </td> <td align="right"> 0 </td> <td align="right"> 76 </td> <td align="right"> 83 </td> <td align="right"> 336 </td> <td align="right"> 204 </td> <td align="right"> 0 </td> </tr>
  <tr> <td align="right"> 4 </td> <td> YEARLY </td> <td align="right"> 0 </td> <td align="right"> 245 </td> <td align="right"> 58 </td> <td align="right"> 102 </td> <td align="right"> 83 </td> <td align="right"> 146 </td> <td align="right"> 11 </td> </tr>
   </table>
Makridakis et al, 2000

Data from forecasting competitions
==============
transition: none
### Tourism
<!-- html table generated in R 3.3.1 by xtable 1.8-2 package -->
<!-- Sat Oct 15 14:44:45 2016 -->
<table border=1>
<tr> <th>  </th> <th> Period </th> <th> TOURISM </th>  </tr>
  <tr> <td align="right"> 1 </td> <td> MONTHLY </td> <td align="right"> 366 </td> </tr>
  <tr> <td align="right"> 2 </td> <td> QUARTERLY </td> <td align="right"> 427 </td> </tr>
  <tr> <td align="right"> 3 </td> <td> YEARLY </td> <td align="right"> 518 </td> </tr>
   </table>
Athanasopoulos et al, 2011

M1
=====================
![m1](images/m1-results)

M3
=====================
![m3](images/m3-results)


Tourism
=====================
![tourism](images/tourism-results)

