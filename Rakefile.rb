

# Notes on getting things set up
# 
# The ios-driver repo needs to be built with:
# `mvn package -Dmaven.test.skip=true`
# 
# And you need to run the server (server-standalone-1.0.0-SNAPSHOT.jar):
# `java -jar server-standalone-1.0.0-SNAPSHOT.jar -aut ~/Documents/build/myapp.app -port 4444`
# 
# Then, `rake run` or whatever.
# 
# I had to do some things before it would work correctly, like make
# something in my xcode dir world read/writable, and also some stuff
# in my ~/Library needed to be chowned to me.
# 
# 









cpl = ['/Users/carl/prog/ios-driver/client/target/ios-client-1.0.0-SNAPSHOT.jar',
       '/Users/carl/prog/ios-driver/common/target/ios-common-1.0.0-SNAPSHOT.jar',
       '/Users/carl/Downloads/commons-codec-1.7.jar',
       '/Users/carl/Downloads/commons-io-2.4.jar',
       '/Users/carl/Downloads/commons-logging-1.1.1.jar',
       '/Users/carl/Downloads/httpclient-4.2.1.jar',
       '/Users/carl/Downloads/httpcore-4.2.1.jar',
      '/Users/carl/Downloads/servlet-api-5.5.12.jar',
       '/Users/carl/Downloads/json-20090211.jar'
      ]

def talkysystem(s, e="An error occurred!")
  puts s
  system(s)
  raise e unless $?.success?
end

task :build do |t|
  puts '*** building ***'
  cmd = "javac -Xlint -classpath #{cpl.join(':')} Try.java"
  talkysystem(cmd)
end

task :run => [:build] do |t|
  puts '*** running ***'
  cmd = "java -classpath #{cpl.join(':')}:. Try"
  talkysystem(cmd)
end
