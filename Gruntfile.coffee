module.exports = (grunt) ->
  grunt.loadNpmTasks "grunt-contrib"
  grunt.loadNpmTasks "grunt-bake"

  # Specifics tasks
  grunt.registerTask "html", ["bake:html", "copy:img", "copy:code"]
  grunt.registerTask "style", ["copy:css", "less"]
  grunt.registerTask "script", ["copy:js", "copy:coffee", "coffee"]

  # General tasks
  grunt.registerTask "build", ["html", "style", "script"]
  grunt.registerTask "dev", ["connect", "watch"]
  grunt.registerTask "default", ["clean", "build"]

  # Parameters
  input = "src"
  output = "target"
  # Scripts
  scriptInput = "#{input}/scripts/"
  scriptOutput = "#{output}/scripts/"
  # Styles
  styleInput = "#{input}/styles/"
  styleOutput = "#{output}/styles/"

  grunt.initConfig
    pkg: grunt.file.readJSON "package.json"

  # dir/files settings
    clean: [output]

  # Server
    connect:
      server:
        options:
          debug: on
          useAvailablePort: on
          base: output
          hostname: "*"
          open: on

  # Watch
    watch:
      options:
        livereload: on
      html:
        files: [
          "#{input}/**/*.html"
          "#{input}/code/*.*"
          "#{input}/images/*.*"
        ]
        tasks: "html"
      style:
        files: "#{styleInput}/**/*.*"
        tasks: "style"
      js:
        files: "#{scriptInput}**/*.*"
        tasks: "script"

  # Copy Tasks
    copy:
      code:
        expand: on
        flatten: on
        src: "#{input}/code/*.*"
        dest: "#{output}/code"
      img:
        files: [
          expand: on
          cwd: "#{input}/images/"
          src: "*.*"
          dest: "#{output}/images/"
        ]
      css:
        expand: on
        flatten: on
        src: "#{styleInput}/*.css"
        dest: "#{styleOutput}"
      js:
        expand: on
        flatten: on
        src: "#{scriptInput}/*.js"
        dest: "#{scriptOutput}"
      coffee:
        expand: on
        flatten: on
        src: "#{scriptInput}/*.coffee"
        dest: "#{scriptOutput}"

  # Build Javascript file from Coffeescript
    coffee:
      main:
        options:
          join: on
          sourceMap: off # set at on to generate map file
        files: [
          expand: on
          cwd: "#{scriptOutput}/"
          src: "*.coffee"
          dest: "#{scriptOutput}"
          ext: ".js"
        ]

  # Build CSS file from Less
    less:
      all:
        options:
          compress: on
          sourceMap: off # set at on for mapping
        files:
          "target/styles/main.css": "#{styleInput}/main.less"
          "target/styles/print.css": "#{styleInput}/print.less"

  # Baking
    bake:
      html:
        options:
          content: "package.json"
        files:
          "target/index.html": "#{input}/index.html"
