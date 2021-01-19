#!/usr/bin/env ruby
# encoding=utf-8
# Author : woh
# License: MIT
require 'to_regexp'
module Avn
  module Filter
    # Using public service from Lauxanh (https://github.com/lauxanh/I-A/blob/master/list-1.txt)
    # Lauxanh is one of the best online services for Vietnamese young people;)
    @@source = File.join(File.dirname(__FILE__), "badwords.txt")
    @@regs = nil
    @@regs_users = {}

    def regs
      @@regs
    end

    def build(source_file = nil)
      file_name = (source_file || @@source)
      return nil unless File.exist?(file_name)
      regs_loaded = File.open(file_name, "r:utf-8").readlines.map(&:strip)
      regs_found = regs_loaded.map do |reg|
        st = "/\\b#{reg.split.join.split("").join("\\p{^L}{0,4}")}\\b/i"
        st.to_regexp
      end
      @@regs = regs_found unless source_file
      regs_found
    end

    def match(st, username = nil)
      rawst = st.to_s.split.join(" ")
      found = @@regs.detect{|reg| rawst.match(reg) }
      found ? {reg: found, rawst: rawst}: nil
    end
  end
end
if $0 == __FILE__
  include Avn::Filter
  Avn::Filter::build
  puts Avn::Filter::regs
  [
   "mó    đ.é+o so",
   "dek",
   "a đ.é+o",
   "owncloud",
   "f**ck",
   "f***ck",
   "wtf?",
   "w.t+f",
   "đmclgt",
   "v cl",
   "clgt",
   "vv cl",
   "hôm qua mình vừa chém xong. mình cũng có đặt 1 quyển rồi. chắc 2 tuần nữa thì về,",
  ].each do |w|
    f = Avn::Filter::match(w)
    puts "#{w} -> #{f.inspect}"
  end
end
