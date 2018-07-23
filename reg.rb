#!/usr/bin/env ruby
# encoding=utf-8
# Author : woh
# License: MIT
require 'to_regexp'
module Avn
  module Filter
    @@source = File.join(File.dirname(__FILE__), "badwords.txt")
    @@regs = nil
    def build
      regs = File.open(@@source, "r:utf-8").readlines.map(&:strip)
      @@regs = regs.map do |reg|
        st = "/\\b#{reg.split.join.split("").join("\\p{^L}{0,4}")}\\b/i"
        st.to_regexp
      end
      @@regs
    end
    def match(st)
      rawst = st.to_s.split.join(" ")
      found = @@regs.detect{|reg| rawst.match(reg) }
      found ? {reg: found, rawst: rawst}: nil
    end
  end
end
if $0 == __FILE__
  include Avn::Filter
  Avn::Filter::build
  [
   "mó    đ.é+o so",
   "dek",
   "a đ.é+o",
   "owncloud",
   "f**ck",
   "f***ck",
   "wtf?",
   "w.t+f",
   "v cl",
   "clgt",
   "vv cl",
   "hôm qua mình vừa chém xong. mình cũng có đặt 1 quyển rồi. chắc 2 tuần nữa thì về,",
  ].each do |w|
    f = Avn::Filter::match(w)
    puts "#{w} -> #{f.inspect}"
  end
end
