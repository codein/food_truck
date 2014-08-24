path = require('path')

module.exports = (grunt) ->

  # Project configuration.
  grunt.initConfig
    pkg: grunt.file.readJSON("package.json")
    uglify:
      options:
        banner: "/*! <%= pkg.name %> <%= grunt.template.today(\"yyyy-mm-dd\") %> */\n"

      # build:
      #   src: "src/<%= pkg.name %>.js"
      #   dest: "build/<%= pkg.name %>.min.js"

    coffee:
      compile:

        files:
          'js/index.js': 'src/**/*.coffee'
        # dest: 'docroot',
        # ext: '.js'

    watch:
      app:
        files: [
          'src/**/*.coffee'
        ]
        tasks:['build']
        options:
          atBegin: true

  # Load the plugin that provides the "uglify" task.
  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks 'grunt-contrib-watch'


  grunt.registerTask 'build', () ->
    tasks = [
      'coffee:compile'
    ]

    grunt.task.run(tasks)