<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>RasMol Documentation</title>
    <link rel="stylesheet" href="style.css">
    <script type="module" src="script.js"></script>
</head>
<body><header><a href="http://www.iucr.org/iucr-top/welcome.html">
<img alt="[IUCr Home Page]" src="html_graphics/iucrhome.jpg"></a>
<a href="http://www.iucr.org/iucr-top/cif/home.html">
<img alt="[CIF Home Page]" src="html_graphics/cifhome.jpg"></a>
<a href="rasmol.html"><img src="html_graphics/rasmolbutton.jpg"
alt="[RasMol Manual]"></a>
<hr>
<nav aria-label="Main Navigation"><div class="center">
| <a href="http://www.rasmol.net">RasMol</a> |
<a href="readme.html#copying">Copying and Distribution</a> |
<a href="readme.html#contents">Contents</a> |
<a href="install.html">Installation Instructions</a> |<br>
| <a href="changelog.html">Changes</a> |
<a href="todo.html">Things To Do</a> |
<a href="readme.html#introduction">Introduction</a> |
<a href="readme.html#codeandbinaries">Source Code and Binaries</a> |<br>
| <a href="rasmol.html">RasMol Manual</a> |
<a href="esrasmol2721.html">Spanish Translation of RasMol Manual</a> |
<a href="itrasmol.hlp">Italian Translation of RasMol Help File</a> |<br>
| <a href=http://www.rasmol.net/donate.shtml>Donate to Support RasMol</a> |
<a href="readme.html">Release README</a> |
<a href=http://www.rasmol.net/register.shtml>Register your RasMol</a> |
<br />
</div></nav></header><main>


<h1 >README<br>
RasMol 2.7.5.2</h1>

<h2 >
Molecular Graphics Visualisation Tool<br />
3 June 2009 (rev. 13 May 2011)<br />
</h2>

<div class="center">
Based on RasMol 2.6
by
Roger Sayle<br />
Biomolecular Structures Group,
Glaxo Wellcome Research &amp; Development,
Stevenage, Hertfordshire, UK<br />
Version 2.6, August 1995, Version 2.6.4, December 1998<br />
Copyright (c) Roger Sayle 1992-1999
</div>
<p>
<div class="center">
and Based on Mods by
<div class="legacy-table">
  <div class="legacy-tr"><div class="legacy-th">Author</div><div class="legacy-th">Version, Date</div><div class="legacy-th">Copyright</div></div>
  <div class="legacy-tr">
    <div class="legacy-td">Arne Mueller</div>
    <div class="legacy-td">RasMol 2.6x1 May 1998</div>
    <div class="legacy-td">(c) Arne Mueller 1998</div>
  </div>
  <div class="legacy-tr">
    <div class="legacy-td">Gary Grossman and<br>Marco Molinaro</div>
    <div class="legacy-td">RasMol 2.5-ucb November 1995<br>RasMol 2.6-ucb November 1996</div>
    <div class="legacy-td">(c) UC Regents/ModularCHEM<br>Consortium 1995, 1996</div>
  </div>
  <div class="legacy-tr">
    <div class="legacy-td">Philippe Valadon</div>
    <div class="legacy-td">RasTop 1.3 August 2000</div>
    <div class="legacy-td">(c) Philippe Valadon 2000</div>
  </div>
  <div class="legacy-tr">
    <div class="legacy-td">Herbert J. Bernstein</div>
    <div class="legacy-td">RasMol 2.7.0 March 1999<br>
    RasMol 2.7.1 June 1999<br>RasMol 2.7.1.1 January 2001<br>
    RasMol 2.7.2 August 2000<br>RasMol 2.7.2.1 April 2001<br>RasMol 2.7.2.1.1 January 2004<br>
    RasMol 2.7.3 February 2005<br>RasMol 2.7.3.1 Apr 06<br>RasMol 2.7.4 Nov 07<br>
    RasMol 2.7.4.1 Jan 08<br>RasMol 2.7.4.2 Mar 08<br>
    RasMol 2.7.5 June 2009<br>
    RasMol 2.7.5.1 July 2009<br>
    RasMol 2.7.5.2 May 2011</div>
    <div class="legacy-td">(c) Herbert J. Bernstein 1998-2009</div>
  </div>
</div>
<p>
RasMol 2.7.5 incorporates changes by T. Ikonen, G. McQuillan, N. Darakev
and L. Andrews (via the neartree package).  Work on RasMol 2.7.5
supported in part by grant 1R15GM078077-01 from the National Institute
of General Medical Sciences (NIGMS), U.S. National Institutes of Health
and by grant ER63601-1021466-0009501 from the Office of Biological &amp;
Environmental Research (BER), Office of Science, U. S. Department of
Energy.  RasMol 2.7.4 incorporated  changes by G. Todorov, Nan Jia,
N. Darakev, P. Kamburov, G. McQuillan, and J. Jemilawon. Work on RasMol
2.7.4 supported in part by grant 1R15GM078077-01 from the NIGMS/NIH and
grant ER63601-1021466-0009501 from BER/DOE.  RasMol 2.7.3 incorporates
changes by Clarice Chigbo, Ricky Chachra, and Mamoru Yamanishi.  Work
on RasMol 2.7.3 supported in part by grants DBI-0203064, DBI-0315281
and EF-0312612 from the U.S. National Science Foundation and grant
DE-FG02-03ER63601 from BER/DOE. The content is solely the responsibility
