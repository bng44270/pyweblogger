from flask import Flask, render_template, send_file, request
import os
import re
import sys

webroot = "LOCALPATH"

reload(sys)
sys.setdefaultencoding('utf8')

app = Flask(__name__)

@app.route("/", methods=["GET"])
def LogHome():
  return render_template("root.html", hostlist = sorted(os.listdir(webroot)))
  

@app.route("/getloglist/<loggroup>", method=["GET"])
def GetLogList(loggroup):
  logpath = webroot + "/" + loggroup + "/"
  return render_template("loglist.html", loglist = sorted([[f,os.stat(logpath + f).st_mtime] for f in os.listdir(logpath)],key=lambda x: x[1], reverse=True))

@app.route("/getlog/<loggroup>/<file>/tail/<pagelength>/<usepage>",defaults={'searchtext':None}, method=["GET"])
@app.route("/getlog/<loggroup>/<file>/tail/<pagelength>/<usepage>/<searchtext>",method=["GET"])
def GetLogTail(loggroup,file,pagelength,usepage,searchtext):
  logfile = webroot + "/" + loggroup + "/" + file
  
  with open(logfile,"r") as f:
    content = f.readlines()

  if searchtext:
    logcontent = "\n".join([a for a in content[pagelength*(usepage-1):pagelength*usepage] if a.find(searchtext) > -1]).replace("\n\n","\n")
  else:
    logcontent = "\n".join(content[pagelength*(usepage-1):pagelength*usepage]).replace("\n\n","\n")

  return render_template("viewlog.html", logcontent = logcontent)
  

@app.route("/getlog/<loggroup>/<file>/tail/<pagelength>/<usepage>",defaults ={'searchtext':None}, method=["GET"])
@app.route("/getlog/<loggroup>/<file>/tail/<pagelength>/<usepage>/<searchtext>",method=["POST"])
def GetLogTail(loggroup,file,pagelength,usepage,searchtext):
  logfile = webroot + "/" + loggroup + "/" + file
  
  with open(logfile,"r") as f:
    content = f.readlines()
  
  if searchtext:
    logcontent = "\n".join([a for a in content[-pagelength*usepage:-pagelength*(usepage-1) if usepage > 1 else None] if a.find(searchtext) > -1]).replace("\n\n","\n")
  else:
    logcontent = "\n".join(content[-pagelength*usepage:-pagelength*(usepage-1) if usepage > 1 else None]).replace("\n\n","\n")
  
  return render_template("viewlog.html", logcontent = logcontent)
  
@app.route("/assets/js/jquery-3.1.1.min.js")
def GetJqueryJs():
  return render_template("jquery-3.1.1.min.js")

@app.route("/assets/img/progress.gif")
def GetProgressBar():
  return send_file("progress.gif")

@app.errorhandler(500)
def internal_error(exception):
  app.logger.error(exception)
  return render_template('error.html', errortext = exception), 500
  
app.run("0.0.0.0",WEBPORT)
