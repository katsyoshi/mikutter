# -*- coding: utf-8 -*-

miquire :boot, 'delayer'
miquire :core, 'miquire_plugin'

using Miquire::ToSpec

Miquire::Plugin.loadpath << Environment::PLUGIN_PATH << File.join(File.dirname(__FILE__), "..", "..", "plugin") << File.join(Environment::CONFROOT, 'plugin')

writer = lambda do |spec|
  depends = Miquire::Plugin.depended_plugins(spec)
  if (depends or []).empty?
    puts "  #{spec[:slug]};"
  else
    depends.each do |depend|
      puts "  #{spec[:slug]} -> #{depend[:slug]};"
    end
  end
end

puts 'digraph mikutter_plugin {'

if Array(Mopt.plugin).empty?
  Miquire::Plugin.each_spec(&writer)
else
  available = Array(Mopt.plugin).inject(Set.new(Array(Mopt.plugin))){|depends, depend_slug|
    depends + Miquire::Plugin.depended_plugins(depend_slug, recursive: true).
      map{|spec| spec[:slug] }}
  available.map{|x| x.to_spec }.each(&writer)
end

puts '}'
