#!/usr/bin/env ruby

require 'tmpdir'

V = "2.5.3"
MJ = "MathJax-#{V}"
url = "https://github.com/mathjax/MathJax/archive/#{V}.tar.gz"
tmpfile = '/tmp/mathjax.tar.gz'
minus_png = '/tmp/mathjax-minus-png.tar.gz'

if not File.exists? tmpfile
  puts "Downloading #{url} > #{tmpfile}"
  system "curl -L #{url} > #{tmpfile}"
end

if not File.exists? minus_png
  puts "Stripping pngs in #{minus_png}"
  Dir.mktmpdir do |wd|
    Dir.chdir(wd)
    system "tar -xzf #{tmpfile}"
    system "rm -r #{MJ}/fonts/HTML-CSS/TeX/png"
    system "tar -czf #{minus_png} #{MJ}"
  end
end

def mean(arr)
  arr.reduce(:+).to_f / arr.size
end

full_size = File.stat(tmpfile).size * 1e-6
puts "full size: #{full_size.round(1)}MB"

minus_png_size = File.stat(minus_png).size * 1e-6
puts "minus png size: #{minus_png_size.round(1)}MB"

size_ratio = (1 - minus_png_size.to_f / full_size)
puts "#{(100 * size_ratio).to_i}% size reduction"

n = 3

Dir.mktmpdir do |wd|
  Dir.chdir(wd)
  t_full = []
  
  n.times do
    tic = Time.now
    system "tar -xzf #{tmpfile}"
    toc = Time.now
    system "rm -rf #{MJ}"
    t_full.push(toc-tic)
  end
  puts "full times: #{t_full}"
  
  t_minus_png = []
  
  n.times do
    tic = Time.now
    system "tar -xzf #{minus_png}"
    toc = Time.now
    system "rm -rf #{MJ}"
    t_minus_png.push(toc-tic)
  end
  puts "minus png: #{t_minus_png}"
  
  time_ratio = 1 - (mean(t_minus_png) / mean(t_full))
  puts "#{(100 * time_ratio).to_i}% time savings"
end
