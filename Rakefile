# -*- coding: utf-8 -*-
require "bundler/gem_tasks"
task :default => :spec

Dir.glob(File.join(__dir__, 'tasks', '*.rake')) do |filename|
  load filename
end
