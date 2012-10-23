

# Notes on getting things set up
# 
# The ios-driver repo needs to be built with:
# `mvn package -Dmaven.test.skip=true`
# 
# And you need to run the server (server-standalone-1.0.0-SNAPSHOT.jar):
# `rake server`
# 
# Then, `rake run` or whatever.
# 
# I had to do some things before it would work correctly, like make
# something in my xcode dir world read/writable, and also some stuff
# in my ~/Library needed to be chowned to me.
# 
# 




ENV['APP_DIR'] ||= '~/Documents/build/InternationalMountains.app'
ENV['APP_NAME'] ||= 'InternationalMountains'
ENV['APP_VERSION'] ||= '1.1'



def talkysystem(s, e="An error occurred!")
  puts s
  system(s)
  raise e unless $?.success?
end

task :build do |t|
  puts '*** building ***'
  cmd = "javac -Xlint Try.java"
  talkysystem(cmd)
end

task :run => [:build] do |t|
  puts '*** running ***'
  cmd = "java -cp #{ENV['CLASSPATH']}:. Try"
  talkysystem(cmd)
end

task :server do |t|
  puts '*** starting selenium+ios-driver standalone server ***'
  talkysystem("java -jar jarbin/server-standalone-1.0.0-SNAPSHOT.jar -aut #{ENV['APP_DIR']} -port 4444")
end

task :rubytry do |t|
  talkysystem("ruby try.rb")
end
