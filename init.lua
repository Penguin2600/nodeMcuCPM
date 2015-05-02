print('mode=', wifi.getmode())
print('MAC: ', wifi.sta.getmac())
print('chip: ', node.chipid())
print('heap: ', node.heap())

print('Entering AP Mode')
wifi.setmode(wifi.SOFTAP)
cfg={}
cfg.ssid="confignet01"
cfg.pwd=nill
wifi.ap.config(cfg)
print('Starting Counter')

pulse_in = 3
led = 1

gpio.mode(led, gpio.OUTPUT)
gpio.mode(pulse_in, gpio.INT)

cpmArray="22, 222, 2"
cpmNow = 0
cpmLucid = 0

function increment()
     cpmNow=cpmNow+1
     print(cpmNow)
end
gpio.trig(pulse_in, "up", increment)

function pushCPM()
    print(cpmArray)
    cpmArray=cpmArray..", "..cpmNow
    cpmNow=0
end

-- start server --
srv=net.createServer(net.TCP)
srv:listen(80,function(conn)
    conn:on("receive", function(client,request)
        local buf = "";
        local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
        if(method == nil)then
            _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP");
        end
        buf = buf..'<script>var counts=['..cpmArray..'];</script>'
        buf = buf..'<h1>Cosmic Ray CPM Chart</h1><canvas id="myCanvas" width="900" height="600" style="border:3px solid #d3d3d3;">';
        buf = buf..'<script>var c=document.getElementById("myCanvas"),ctx=c.getContext("2d"),height=600,width=900;for(i=0;i<height;i+=50)ctx.fillText(i,5,height-i),ctx.beginPath(),ctx.moveTo(0,height-i),ctx.lineTo(width,height-i),ctx.strokeStyle="#d3d3d3",ctx.stroke();for(i=0;i<counts.length;i++){var count=counts[i];ctx.fillRect(7*i+30,600,1,-1*count)}</script>'
        client:send(buf);
        client:close();
        collectgarbage();
    end)
end)


tmr.alarm(1, 5000, 1, pushCPM)
