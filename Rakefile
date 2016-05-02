task default: :test

task :test do
  require 'rake/testtask'

  files_list = Dir[File.join "test", "**", "*.rb"]
  files      = ENV['file'].split(',') rescue nil
  verbose    = !!ENV['verbose']

  Rake::TestTask.new do |t|
    t.verbose = verbose
    t.test_files = if files
                     files.unshift "helper.rb"
                     files.map do |file|
                       unless index = files_list.index { |f| f.match(/\/#{file}$/) }
                         raise "UnknownFileError #{ file }"
                       end
                       files_list[index]
                     end
                   else
                     files_list
                   end
  end
end
