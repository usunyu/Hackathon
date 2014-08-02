Hackathon
=========

#### Ruby on Rails Env Setup
1. [Homebrew](http://brew.sh/)

        ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"
        brew doctor

2. [Ruby](https://www.ruby-lang.org/en/)

        brew install rbenv
        brew install ruby-build
  
        Add eval "$(rbenv init -)" to .bash_profile

        source ~/.bash_profile
        rbenv install 2.0.0-p481
        rbenv rehash
        rbenv global 2.0.0-p481

3. [RubyGems](https://rubygems.org)

        gem update —system

4. Rails

        gem install bundler
        rbenv rehash
        gem install rails --version 4.1.4
        rbenv rehash

5. MySQL

        brew install mysql
        mysql.server start
        test mysql working mysql -u root
        gem install mysql2
        

#### Setup App
1. Colne Repo

        git clone https://github.com/usunyu/YC-Hackathon

2. Start Local
        
        bundle install
        rails server

#### Test App
1. [Local App](http://localhost:3000/)

2. [Heroku App](http://first-test-project.herokuapp.com/)
