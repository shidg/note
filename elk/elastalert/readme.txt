#https://github.com/Yelp/elastalert
#与elk系统搭配使用，对日志内容进行监控并触发报警 （使用版本v0.1.20）


 nohup python -m elastalert.elastalert --verbose --config /Data/app/elastalert/config.yaml --rule /Data/app/elastalert/example_rules/example_frequency.yaml > /dev/null 2>&1 &
