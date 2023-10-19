---
layout: default
title: SearchRights Table
slug: table
card: "summary"
summary_large_image: True
image: /images/SearchRights_sample2.png_resized.png
image_alt: "Image of the webpage."
date: 2023-09-08 14:59:16 -0700
tags:
location: Everett
author: Daniel Griffin
---
{% assign colspan_size = site.data.systems.size | plus: 1 %}
{% include_cached table_head.html systems=site.data.systems %}
<tbody>
{% for file in site.data.evaluations %}
{% assign evaluation_file = file[1] %}
{% include_cached category_row.html evaluation_file=evaluation_file system_page=false colspan_size=colspan_size %}
{% for criteria in evaluation_file.evaluations %}
<!-- Criteria rows -->
{% include_cached criteria_row.html criteria=criteria system_page=false use_url=true %}
{% endfor %}
{% endfor %}
</tbody>
</table>

<h3>Works Cited</h3>

<div class="mx-3">
{% bibliography %}
</div>