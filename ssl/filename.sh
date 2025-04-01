etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/internet-nginx-172.18.63.86~87/conf.d/20-xyz.conf 'upstream xyz_server {
    server 172.18.64.153:5080 max_fails=3 fail_timeout=30s;
    server 172.18.64.152:5080 max_fails=3 fail_timeout=30s;
}

server {
    underscores_in_headers on;
    # 端口待确认
    listen 443 ssl;
    # 证书待处理
    ssl_certificate ssl/5180658__cloudglab.com.pem;
    ssl_certificate_key ssl/5180658__cloudglab.com.key;

    server_name aaaaaaaaabbbbb.cloudglab.com;
    server_tokens off;
    if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
       set $year $1;
       set $month $2;
       set $day $3;
    }
    #access_log logs/bazsck/access.log.${year}${month}${day};
		# access_log /app/nginx_logs/${year}${month}${day}/${http_host}.access.log;
		access_log /app/nginx_logs/${http_host}.access.log;
		error_log /app/nginx_logs/${http_host}.access.log;
    fastcgi_param HTTPS on;
    fastcgi_param HTTP_SCHEME https;

    #allow 60.190.217.110;
    #allow 183.134.218.236;
    #deny all;
    client_max_body_size   200m;

		location /api/xyz/trace/img/ {
    		rewrite /api/xyz/trace/img/(.*)\.png$ "/api/xyz/trace/img?params={\"taskUUID\":\"$1\"}" last;
		} 

		location /api/xyz/ {
        proxy_set_header Host $host;
        proxy_set_header Host $http_host;
        proxy_set_header Remote-Port $remote_port;
        proxy_set_header X-Real-IP $http_x_real_ip;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass http://xyz_server;
		}

		location ~ ^/xyz|abc {
        proxy_set_header Host $host;
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $http_x_real_ip;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass http://xyz_server;
		}

    location / {
			return 404;
    }

}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/internet-nginx-172.18.63.86~87/conf.d/3-baidu.conf 'upstream api_baidu_map {
     server 172.18.64.129:8600 max_fails=3 fail_timeout=30s;
}

server {
       server_name api.map.baidu.ga.loal;
       index index.html index.htm; 
       
       if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
          set $year $1;
          set $month $2;
          set $day $3;
       }
       access_log logs/$host/access.log.${year}${month}${day};
       
       location / {
                proxy_pass http://api_baidu_map;
       }

}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/internet-nginx-172.18.63.86~87/conf.d/4-pypi.conf 'upstream pypi_mirrors {
     server 172.18.65.129:3141 max_fails=3 fail_timeout=30s;
}

server {
        server_name mirrors.pypi.ga.local;
        index index.html index.htm;
        vhost_traffic_status off;

        if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
            set $year $1;
            set $month $2;
            set $day $3;
        }
        access_log logs/$host/access.log.${year}${month}${day};

        location ~ /(root|\+search) {
        #location ~ /(ga-devpi|\+search) {
                 proxy_pass http://pypi_mirrors;
                 proxy_http_version 1.1;
                 proxy_set_header Connection "";
                 proxy_set_header Host $host;
                 proxy_set_header X-Real-IP $remote_addr;
                 proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }

}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/internet-nginx-172.18.63.86~87/conf.d/5-sdk.conf 'upstream sdk-proxy {
     server 172.18.64.125:39201 max_fails=3 fail_timeout=30s;
     server 172.18.64.126:39201 max_fails=3 fail_timeout=30s;
}

server {
       server_name sdk-proxy.ga.local;
       index index.html index.htm index.php;
       vhost_traffic_status off;
       
       if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
          set $year $1;
          set $month $2;
          set $day $3;
       }
       access_log logs/$host/access.log.${year}${month}${day};
       
       location / {
                proxy_pass http://sdk-proxy;
       }

}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/internet-nginx-172.18.63.86~87/conf.d/6-clouglab.conf 'server {
    listen 80;
    listen 443 ssl;
    server_name www.cloudglab.com;
    access_log logs/access.log.$host;
    underscores_in_headers on;

    ssl_certificate ssl/5180658__cloudglab.com.pem;
    ssl_certificate_key ssl/5180658__cloudglab.com.key;
    ssl_protocols  SSLv2 SSLv3 TLSv1 TLSv1.1 TLSv1.2;
    server_tokens off;

    fastcgi_param HTTPS on;
    fastcgi_param HTTP_SCHEME https;

    
    location /0501 {
         #proxy_pass http://cloudglab.com/status;
         auth_basic "请输入账号密码";
         auth_basic_user_file /app/data/www/passwd;
         alias /app/data/www/0501/dist;
         try_files $uri $uri/ /0501/index.html;
         index index.php index.html index.htm default.php default.htm default.html;

     }
   
    location /1207 {
         #proxy_pass http://cloudglab.com/status;
         auth_basic "请输入账号密码";
         auth_basic_user_file /app/data/www/passwd;
         alias /app/data/www/1207/dist;
         try_files $uri $uri/ /1207/index.html;
         index index.php index.html index.htm default.php default.htm default.html;

     }
    
         location /0308 {
         #proxy_pass http://cloudglab.com/status;
         auth_basic "请输入账号密码";
         auth_basic_user_file /app/data/www/passwd;
         alias /app/data/www/0308/dist;
         try_files $uri $uri/ /0308/index.html;
         index index.php index.html index.htm default.php default.htm default.html;

     }
    location /status {
        allow 127.0.0.1;
        deny all;
        vhost_traffic_status_display;
        vhost_traffic_status_display_format html;
    }

    location / {
        index index.html index.htm index.php;
        root /app/data/www;
    }

}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/internet-nginx-172.18.63.86~87/conf.d/8-bazs.conf 'upstream bazs_server {
 server 172.18.64.153:5080 max_fails=3 fail_timeout=30s;
 server 172.18.64.152:5080 max_fails=3 fail_timeout=30s;
}
server {
    underscores_in_headers on;
    # 端口待确认
    listen 443 ssl;
    # 证书待处理
    ssl_certificate ssl/5180658__cloudglab.com.pem;
    ssl_certificate_key ssl/5180658__cloudglab.com.key;
    #ssl_certificate ssl/5180658__cloudglab.com.pem;
    #ssl_certificate_key ssl/5180658__cloudglab.com.key;

    server_name bazs.cloudglab.com;
    server_tokens off;
    if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
       set $year $1;
       set $month $2;
       set $day $3;
    }
    access_log logs/bazs/access.log.${year}${month}${day};

    fastcgi_param HTTPS on;
    fastcgi_param HTTP_SCHEME https;


    #allow 60.190.217.110;
    #allow 183.134.218.236;
    #deny all;
    client_max_body_size   200m;

     location =/api/fz_app_case/app/downloadPoliceApk{
        rewrite ^/(.*) https://cdn.cloudglab.com/bazspo-1.0.21.apk redirect;

     }

     location =/api/fz_app_case/app/downloadApk{
        rewrite ^/(.*) https://cdn.cloudglab.com/bazs-1.0.35.apk redirect;

     }

     location =/api/fz_app_case/app/downloadSimpleApk{
        rewrite ^/(.*) https://cdn.cloudglab.com/bazs-1.0.35.apk redirect;
    }
    location /res {
    add_header Content-Type "application/octet-stream";
    add_header Content-Disposition "attachment; filename=bazs-1.0.35.apk";
    alias /app/data/www/fzapk/bazs-1.0.35.apk;
    }

    location ~/api/(fz_app_case|fz_user|behavior)/ {
        proxy_set_header Host bazs.cloudglab.cn;
        proxy_set_header X-Real-IP $http_x_real_ip;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass http://bazs_server;
    }
 
    location ~/api/(auth|administrate)/user/(sendAuthCode|login|logout|getLoginInfo|verifyAuthCode) {
        proxy_set_header Host bazs.cloudglab.cn;
        proxy_set_header X-Real-IP $http_x_real_ip;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass http://bazs_server;
    }

   location ~/for_test/api/(fz_app_case|fz_user)/ {
        proxy_set_header Host bazs.cloudglab.cn;
        proxy_set_header X-Real-IP $http_x_real_ip;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass http://bazs_server;
    }
   location ~/for_test/api/(auth|administrate)/user/(sendAuthCode|login|logout|getLoginInfo|verifyAuthCode) {
        proxy_set_header Host bazs.cloudglab.cn;
        proxy_set_header X-Real-IP $http_x_real_ip;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass http://bazs_server;
    }
  
}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/internet-nginx-172.18.63.86~87/conf.d/9-yc.conf 'upstream yc_server {
    server 172.18.64.153:5080 max_fails=3 fail_timeout=30s;
    server 172.18.64.152:5080 max_fails=3 fail_timeout=30s;
}


# for old yc
server {
       listen 80;
#       listen 5089;
       server_name 51x.cloudglab.com;
       index index.html index.htm; 
       client_max_body_size 1500m;
       underscores_in_headers on;

       if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
          set $year $1;
          set $month $2;
          set $day $3;
       }
       access_log logs/yuncai/access.log.${year}${month}${day};
       
       location / {
           proxy_set_header Host yc.cloudglab.cn;
           proxy_set_header X-Real-IP $http_x_real_ip;
           proxy_set_header    X-Forwarded-For $proxy_add_x_forwarded_for;
           proxy_pass http://yc_server;
       }

       location /yuncai/wifi/scanUploadBigHardWare {
           rewrite ^/(\w+)/(\w+)/(\w+)$ /yuncai_app/log_upload/scan_upload/asd_upload break;
           proxy_http_version 1.1;
           proxy_set_header Connection "";
           proxy_pass http://yc_server;
           proxy_set_header Host yc.cloudglab.cn;
           proxy_set_header X-Real-IP $http_x_real_ip;
           proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
       
}

# for new yc
server {
       listen 443 ssl;
       server_name yc.cloudglab.com;

       ssl_certificate ssl/5180658__cloudglab.com.pem;
       ssl_certificate_key ssl/5180658__cloudglab.com.key;

       fastcgi_param HTTPS on;
       fastcgi_param HTTP_SCHEME https;

       if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
          set $year $1;
          set $month $2;
          set $day $3;
       }
       access_log logs/yuncai/access.log.${year}${month}${day};

       location / {
           proxy_set_header Host yc.cloudglab.cn;
           proxy_set_header X-Real-IP $http_x_real_ip;
           proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
           proxy_pass http://yc_server;
       }
       
       root /app/data/www/yjzs/yc_apk_download;
       
       location /yuncai_app {
           proxy_set_header Host yc.cloudglab.cn;
           proxy_set_header X-Real-IP $http_x_real_ip;
           proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
           proxy_pass http://yc_server;
       }
   
       location /api {
           proxy_set_header Host yc.cloudglab.cn;
           proxy_set_header X-Real-IP $http_x_real_ip;
           proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
           proxy_pass http://yc_server;
       }
   
       location /yjzs/apk-download {
            add_header Content-Security-Policy upgrade-insecure-requests;
            alias /app/data/www/yjzs/yc_apk_download;
            autoindex off;
       }
}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/internet-nginx-172.18.63.86~87/nginx.conf 'user  root;
worker_processes 16;
load_module "/opt/nginx/lib/ngx_stream_module.so";

error_log      logs/error.log error;
pid     /run/nginx.pid;

worker_rlimit_nofile 65535;

events {
	use epoll;
	worker_connections  65535;
}

http {
      server_tokens off;
      include       mime.types;
      client_max_body_size 200M;
      client_body_buffer_size 50m;
      default_type  application/octet-stream;
      log_format  main '$remote_addr – $remote_user [$time_local] $request '
      		' $status $body_bytes_sent "$http_referer" '
      		' "$http_user_agent" "$http_x_forwarded_for" '
      		' "$msec" "$host" '
      		' "$upstream_addr $upstream_status $upstream_response_time $request_time"';

      sendfile on;
      keepalive_timeout 65;

      client_header_buffer_size 128k;
      large_client_header_buffers 4 128k;

      gzip on;
      gzip_min_length	1k;
      gzip_buffers	4 16k;
      gzip_http_version 1.1;
      gzip_comp_level	2;
      gzip_types	text/plain application/x-javascript text/css application/xml;
      gzip_vary on;
      gzip_disable "MSIE [1-6]\.";

      proxy_buffer_size  32k;
      proxy_buffers   8 64k;

      vhost_traffic_status_zone shared:vhost_traffic_status:10m;
      vhost_traffic_status_filter_by_host on;

#      include	vhosts/*.conf;
      include conf.d/*.conf;
}

stream {
       log_format proxy '$remote_addr [$time_local] '
                 '$protocol $status $bytes_sent $bytes_received '
                 '$session_time "$upstream_addr" '
                 '"$upstream_bytes_sent" "$upstream_bytes_received" "$upstream_connect_time"';
       access_log logs/tcp.log proxy;
       include stream/*.conf;
}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/internet-nginx-172.18.63.86~87/stream/ ''
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/internet-nginx-172.18.63.86~87/stream/5080.conf 'upstream k8s_server{
  server 172.18.64.200:5080;
  server 172.18.64.201:5080;
  server 172.18.64.202:5080;
  server 172.18.64.153:5080;
  server 172.18.64.152:5080;
}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/proxy-nginx-172.18.65.104/ ''
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/proxy-nginx-172.18.65.104/conf.d/ ''
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/proxy-nginx-172.18.65.104/conf.d/1-baidu.conf '# api.map.baidu.com
server {
    server_name api.map.baidu.ga.local;
    index index.html index.htm;

    if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
        set $year $1;
        set $month $2;
        set $day $3;
    }
    access_log /var/log/nginx/baidu-access.log.${year}${month}${day};

    location / {
             proxy_pass http://api.map.baidu.com;
    }

}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/proxy-nginx-172.18.65.104/conf.d/10-bdfz-message.conf 'server {
    server_name bdfz-message-yxt-prod.ga.local;
    index index.html index.htm;

    if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
        set $year $1;
        set $month $2;
        set $day $3;
    }
    access_log /var/log/nginx/bdfz-message-yxt-access.log.${year}${month}${day};

    location / {
             proxy_pass  http://115.239.137.23:9501;
    }

}

server {
    server_name bdfz-message-yxt-dev.ga.local;
    index index.html index.htm;

    if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
        set $year $1;
        set $month $2;
        set $day $3;
    }
    access_log /var/log/nginx/bdfz-message-yxt-access.log.${year}${month}${day};

    location / {
             proxy_pass  http://119.45.183.149:9501;
    }

}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/proxy-nginx-172.18.65.104/conf.d/11-api.tool.dute.conf 'server {
       listen 443 ssl;
       server_name api.tool.dute.me.ga.local;

       if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
           set $year $1;
           set $month $2;
           set $day $3;
       }
       access_log /var/log/nginx/api.tool.dute.me.log.${year}${month}${day};

       ssl_certificate /etc/nginx/ssl/server.crt;
       ssl_certificate_key /etc/nginx/ssl/server.key;

       ssl_session_cache shared:SSL:10m;
       ssl_session_timeout 5m;

       ssl_protocols SSLv2 SSLv3 TLSv1.2;
       ssl_ciphers HIGH:!aNULL:!MD5;
       ssl_prefer_server_ciphers on;

       location / {
                proxy_pass https://api.tool.dute.me;
       }

}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/proxy-nginx-172.18.65.104/conf.d/12-aliyunmirrors.conf '# mirrors.aliyun.com
server {
    server_name mirrors.aliyun.com.ga.local;
    index index.html index.htm;

    if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
        set $year $1;
        set $month $2;
        set $day $3;
    }
    access_log /var/log/nginx/mirrorsaliyun-access.log.${year}${month}${day};

    location / {
             proxy_pass http://mirrors.aliyun.com;
    }

}

# mirrors.aliyuncs.com
server {
    server_name mirrors.aliyuncs.com.ga.local;
    index index.html index.htm;

    if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
        set $year $1;
        set $month $2;
        set $day $3;
    }
    access_log /var/log/nginx/mirrorsaliyun-access.log.${year}${month}${day};

    location / {
             proxy_pass http://mirrors.aliyuncs.com;
    }

}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/proxy-nginx-172.18.65.104/conf.d/12-bus-jcss.conf 'server {
       listen 80 ;
       server_name bus-jcss.police.hangzhou.gov.cn.ga.local;
       underscores_in_headers on; 
       if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
           set $year $1;
           set $month $2;
           set $day $3;
       }
       access_log /var/log/nginx/bus-jcss.log.${year}${month}${day};

       location / {
                proxy_pass http://bus-jcss.police.hangzhou.gov.cn;
       }

}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/proxy-nginx-172.18.65.104/conf.d/2-getui.conf '# openapi-smsp.getui.com
server {
       server_name openapi-smsp.getui.com;

       if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
           set $year $1;
           set $month $2;
           set $day $3;
       }
       access_log /var/log/nginx/openapi-smsp.getui.com.${year}${month}${day};

			 proxy_ssl_verify off;
       location / {
                proxy_pass https://openapi-smsp.getui.com;
       }

}
# openapi-smsp.getui.com
server {
       listen 443 ssl;
       server_name openapi-smsp.getui.ga.local;

       if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
           set $year $1;
           set $month $2;
           set $day $3;
       }
       access_log /var/log/nginx/getui-access.log.${year}${month}${day};

       ssl_certificate /etc/nginx/ssl/server.crt;
       ssl_certificate_key /etc/nginx/ssl/server.key;

       ssl_session_cache shared:SSL:10m;
       ssl_session_timeout 5m;

       ssl_protocols SSLv2 SSLv3 TLSv1.2;
       ssl_ciphers HIGH:!aNULL:!MD5;
       ssl_prefer_server_ciphers on;

       location / {
                proxy_pass https://openapi-smsp.getui.com;
       }

}

# restapi.getui.com
server {
       listen 443 ssl;
       server_name restapi.getui.ga.local;

       if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
           set $year $1;
           set $month $2;
           set $day $3;
       }
       access_log /var/log/nginx/getui-access.log.${year}${month}${day};

       ssl_certificate /etc/nginx/ssl/server.crt;
       ssl_certificate_key /etc/nginx/ssl/server.key;

       ssl_session_cache shared:SSL:10m;
       ssl_session_timeout 5m;

       ssl_protocols SSLv2 SSLv3 TLSv1.2;
       ssl_ciphers HIGH:!aNULL:!MD5;
       ssl_prefer_server_ciphers on;

       location / {
                proxy_pass https://restapi.getui.com;
       }

}

# openapi-gy.getui.com
server {
       listen 443 ssl;
       server_name openapi-gy.getui.ga.local;

       if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
           set $year $1;
           set $month $2;
           set $day $3;
       }
       access_log /var/log/nginx/getui-access.log.${year}${month}${day};

       ssl_certificate /etc/nginx/ssl/server.crt;
       ssl_certificate_key /etc/nginx/ssl/server.key;

       ssl_session_cache shared:SSL:10m;
       ssl_session_timeout 5m;

       ssl_protocols SSLv2 SSLv3 TLSv1.2;
       ssl_ciphers HIGH:!aNULL:!MD5;
       ssl_prefer_server_ciphers on;

       location / {
                proxy_pass https://openapi-gy.getui.com;
       }

}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/proxy-nginx-172.18.65.104/conf.d/3-qq.conf 'server {
       listen 443 ssl;
       server_name qyapi.weixin.qq.ga.local;

       ssl_certificate /etc/nginx/ssl/server.crt;
       ssl_certificate_key /etc/nginx/ssl/server.key;

       ssl_session_cache shared:SSL:10m;
       ssl_session_timeout 5m;

       ssl_protocols SSLv2 SSLv3 TLSv1.2;
       ssl_ciphers HIGH:!aNULL:!MD5;
       ssl_prefer_server_ciphers on;

       if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
           set $year $1;
           set $month $2;
           set $day $3;
       }
       access_log /var/log/nginx/qq-access.log.${year}${month}${day};

       location / {
                proxy_pass https://qyapi.weixin.qq.com;
       }

}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/proxy-nginx-172.18.65.104/conf.d/4-yum.conf 'server {
       server_name mirrors.cloudglab.ga.local;
       listen 80;
       root /app/ga-repo;

       if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
           set $year $1;
           set $month $2;
           set $day $3;
       }
       access_log /var/log/nginx/yum-access.log.${year}${month}${day};

}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/proxy-nginx-172.18.65.104/conf.d/5-aliyun.conf 'server {
       server_name cloudauth.aliyuncs.ga.local;

       if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
           set $year $1;
           set $month $2;
           set $day $3;
       }
       access_log /var/log/nginx/aliyun-access.log.${year}${month}${day};


       location / {
                proxy_pass https://cloudauth.aliyuncs.com;
       }

}

server {
       server_name mirrors.pypi.ga.local;

       if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
           set $year $1;
           set $month $2;
           set $day $3;
       }
       access_log /var/log/nginx/aliyun-access.log.${year}${month}${day};


       location / {
                proxy_pass https://mirrors.aliyun.com;
       }

}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/proxy-nginx-172.18.65.104/conf.d/6-chinaz.com '# seo.chinaz.com
server {
       listen 443 ssl;
       server_name  ~^(?<subdomain>.+).chinaz.ga.local$;

       if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
           set $year $1;
           set $month $2;
           set $day $3;
       }
       access_log /var/log/nginx/${subdomain}-chinaz-access.log.${year}${month}${day};

       ssl_certificate /etc/nginx/ssl/server.crt;
       ssl_certificate_key /etc/nginx/ssl/server.key;

       ssl_session_cache shared:SSL:10m;
       ssl_session_timeout 5m;

       ssl_protocols SSLv2 SSLv3 TLSv1.2;
       ssl_ciphers HIGH:!aNULL:!MD5;
       ssl_prefer_server_ciphers on;
			 
       location / {
                set $url "${subdomain}.chinaz.com";
                proxy_pass https://$url;
       }

}

# seo.chinaz.com
server {
       listen 443 ssl;
       server_name seo.chinaz.ga.local;

       if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
           set $year $1;
           set $month $2;
           set $day $3;
       }
       access_log /var/log/nginx/chinaz-access.log.${year}${month}${day};

       ssl_certificate /etc/nginx/ssl/server.crt;
       ssl_certificate_key /etc/nginx/ssl/server.key;

       ssl_session_cache shared:SSL:10m;
       ssl_session_timeout 5m;

       ssl_protocols SSLv2 SSLv3 TLSv1.2;
       ssl_ciphers HIGH:!aNULL:!MD5;
       ssl_prefer_server_ciphers on;

       location / {
                proxy_pass https://seo.chinaz.com;
       }

}

# seo.chinaz.com
server {
       server_name seo.chinaz.ga.local seo.chinaz.com.ga.local;

       if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
           set $year $1;
           set $month $2;
           set $day $3;
       }
       access_log /var/log/nginx/seo-chinaz-access.log.${year}${month}${day};


       location / {
                proxy_pass https://seo.chinaz.com;
       }

}


# icp.chinaz.com
server {
       server_name icp.chinaz.ga.local icp.chinaz.com.ga.local;

       if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
           set $year $1;
           set $month $2;
           set $day $3;
       }
       access_log /var/log/nginx/chinaz-access.log.${year}${month}${day};


       location / {
                proxy_pass https://icp.chinaz.com;
       }

}
# icp.chinaz.com
server {
       listen 443 ssl;
       server_name icp.chinaz.ga.local icp.chinaz.com.ga.local;

       if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
           set $year $1;
           set $month $2;
           set $day $3;
       }
       access_log /var/log/nginx/chinaz-access.log.${year}${month}${day};

       ssl_certificate /etc/nginx/ssl/server.crt;
       ssl_certificate_key /etc/nginx/ssl/server.key;

       ssl_session_cache shared:SSL:10m;
       ssl_session_timeout 5m;

       ssl_protocols SSLv2 SSLv3 TLSv1.2;
       ssl_ciphers HIGH:!aNULL:!MD5;
       ssl_prefer_server_ciphers on;

       location / {
                proxy_pass https://icp.chinaz.com;
       }

}
# whois.chinaz.com
server {
       server_name whois.chinaz.ga.local whois.chinaz.com.ga.local;

       if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
           set $year $1;
           set $month $2;
           set $day $3;
       }
       access_log /var/log/nginx/chinaz-access.log.${year}${month}${day};


       location / {
                proxy_pass https://whois.chinaz.com;
       }

}

# whois.chinaz.com
server {
       listen 443 ssl;
       server_name whois.chinaz.ga.local whois.chinaz.com.ga.local;

       if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
           set $year $1;
           set $month $2;
           set $day $3;
       }
       access_log /var/log/nginx/chinaz-access.log.${year}${month}${day};

       ssl_certificate /etc/nginx/ssl/server.crt;
       ssl_certificate_key /etc/nginx/ssl/server.key;

       ssl_session_cache shared:SSL:10m;
       ssl_session_timeout 5m;

       ssl_protocols SSLv2 SSLv3 TLSv1.2;
       ssl_ciphers HIGH:!aNULL:!MD5;
       ssl_prefer_server_ciphers on;

       location / {
                proxy_pass https://whois.chinaz.com;
       }

}

#ip.tool.chinaz.com
server {
       listen 443 ssl;
       server_name ip.tool.chinaz.ga.local;

       if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
           set $year $1;
           set $month $2;
           set $day $3;
       }
       access_log /var/log/nginx/chinaz-access.log.${year}${month}${day};

       ssl_certificate /etc/nginx/ssl/server.crt;
       ssl_certificate_key /etc/nginx/ssl/server.key;

       ssl_session_cache shared:SSL:10m;
       ssl_session_timeout 5m;

       ssl_protocols SSLv2 SSLv3 TLSv1.2;
       ssl_ciphers HIGH:!aNULL:!MD5;
       ssl_prefer_server_ciphers on;

       location / {
                proxy_pass https://ip.tool.chinaz.com;
       }

}

#ip.tool.chinaz.com
server {
       server_name ip.tool.chinaz.ga.local ip.tool.chinaz.local;

       if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
           set $year $1;
           set $month $2;
           set $day $3;
       }
       access_log /var/log/nginx/tool-chinaz-access.log.${year}${month}${day};


       location / {
                proxy_pass https://ip.tool.chinaz.com;
       }

}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/proxy-nginx-172.18.65.104/conf.d/7-ip138.conf 'server {
       server_name site.ip138.com.ga.local;

       if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
           set $year $1;
           set $month $2;
           set $day $3;
       }
       access_log /var/log/nginx/ip138-access.log.${year}${month}${day};


       location / {
                proxy_pass https://site.ip138.com;
       }

}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/proxy-nginx-172.18.65.104/conf.d/8-jsons.conf 'server {
       listen 443 ssl;
       server_name www.jsons.cn.ga.local;

       ssl_certificate /etc/nginx/ssl/server.crt;
       ssl_certificate_key /etc/nginx/ssl/server.key;

       ssl_session_cache shared:SSL:10m;
       ssl_session_timeout 5m;

       ssl_protocols SSLv2 SSLv3 TLSv1.2;
       ssl_ciphers HIGH:!aNULL:!MD5;
       ssl_prefer_server_ciphers on;

       if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
           set $year $1;
           set $month $2;
           set $day $3;
       }
       access_log /var/log/nginx/jsons-access.log.${year}${month}${day};

       location / {
                proxy_pass http://www.jsons.cn;
       }

}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/proxy-nginx-172.18.65.104/conf.d/9-bugscaner.conf 'server {
    server_name tools.bugscaner.ga.local;
    index index.html index.htm;

    if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
        set $year $1;
        set $month $2;
        set $day $3;
    }
    access_log /var/log/nginx/bugscaner-access.log.${year}${month}${day};

    location / {
             proxy_pass http://tools.bugscaner.com;
    }

}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/proxy-nginx-172.18.65.104/conf.d/k8s_backend.conf 'server {
    underscores_in_headers on;
    listen 8070;
    server_name  localhost;
    resolver 10.254.0.2;
    set $analyzer_backend "http://apkanalyzer.analyzer.svc.cluster.local:3000";
    set $analyzer_wspool "http://analyzer-websocketpool.analyzer.svc.cluster.local:9002";
    client_max_body_size 1500m;
    access_log /var/log/nginx/fz-bazs.log main;
    error_log /var/log/nginx/fz-bazs-error.log error;

    location /ws {
     proxy_pass $analyzer_wspool;
     proxy_http_version 1.1;
     proxy_set_header Upgrade $http_upgrade;
     proxy_set_header Connection "Upgrade";
     proxy_set_header Host $host;
     proxy_set_header X-Real-IP $http_x_real_ip;
     proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
     proxy_read_timeout 300;
    }

    location / {
        proxy_set_header X-Real-IP $http_x_real_ip;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass $analyzer_backend;
    }

}

server {
    underscores_in_headers on;
    listen 8071;
    server_name localhost;
    resolver 10.254.0.2;
    set $fz_backend "http://analyzer-static-api.analyzer.svc.cluster.local:8000";
    client_max_body_size 1500m;
    access_log /var/log/nginx/fz-bazs.log main;


    location / {
        proxy_set_header X-Real-IP $http_x_real_ip;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass $fz_backend;
    }
}

server {
    underscores_in_headers on;
    listen 8072;
    server_name localhost;
    resolver 10.254.0.2;
    set $analyzer_backend "http://apkanalyzer.analyzer-v2.svc.cluster.local:3000";
    set $websocket_backend "http://analyzer-websocketpool.analyzer-v2.svc.cluster.local:9002";
    client_max_body_size 1500m;
    access_log /var/log/nginx/analyzer-v2.log main;
    error_log /var/log/nginx/analyzer-v2.error.log warn;

    location / {
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $http_x_real_ip;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass $analyzer_backend;
    }

    location /ws {
        proxy_pass $websocket_backend;
        proxy_redirect off;
        proxy_set_header X-Real_IP $remote_addr;
        proxy_set_header X-Forwarded-For $remote_addr:$remote_port;
        proxy_http_version 1.1;
        proxy_read_timeout 300;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
    }
}

server {
    underscores_in_headers on;
    listen 8073;
    server_name localhost;
    resolver 10.254.0.2;
    set $static_backend "http://analyzer-static-api.analyzer-v2.svc.cluster.local:8000";
    client_max_body_size 1500m;
    access_log /var/log/nginx/analyzer-v2.log main;
    error_log /var/log/nginx/analyzer-v2.error.log warn;

    location / {
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $http_x_real_ip;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass $static_backend;
    }
}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/proxy-nginx-172.18.65.104/nginx.conf '# For more information on configuration, see:
#   * Official English Documentation: http://nginx.org/en/docs/
#   * Official Russian Documentation: http://nginx.org/ru/docs/

user root;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

# Load dynamic modules. See /usr/share/nginx/README.dynamic.
include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 1024;
}

stream {
      include /etc/nginx/stream/*.conf;
}

http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile            on;
    client_max_body_size 2000m;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 2048;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    # Load modular configuration files from the /etc/nginx/conf.d directory.
    # See http://nginx.org/en/docs/ngx_core_module.html#include
    # for more information.
    include /etc/nginx/conf.d/*.conf;

}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/proxy-nginx-172.18.65.104/stream/ ''
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/proxy-nginx-172.18.65.104/stream/1-mail.conf 'upstream gt_mail_proxy {
        server smtp.getui.com:25;
}

#upstream gt_mails_proxy {
#        server smtp.getui.com:465;
#}

server {
        listen 25;

        proxy_connect_timeout 5s;
        proxy_timeout 5s;
        proxy_pass gt_mail_proxy;
}

#server {
#        listen 465;
#
#        proxy_connect_timeout 5s;
#        proxy_timeout 5s;
#        proxy_pass gt_mails_proxy;
#}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/vpn-nginx-172.18.63.110/ ''
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/vpn-nginx-172.18.63.110/conf.d/0-getui-web-proxy.conf 'upstream bi_getui_server_https{
	server 172.18.251.250:443;
	server 172.18.251.251:443;
}

upstream bi_getui_server_http{
	server 172.18.251.250:80;
	server 172.18.251.251:80;
}
# https
server {
       listen 443 ssl;
    	server_name *.xsbi.getui.com *.bi.getui.com;
    	client_max_body_size 1500m;

    if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
          set $year $1;
          set $month $2;
          set $day $3;
       }
    access_log /app/nginx_logs/${year}${month}${day}/${http_host}.access.log;

       ssl_certificate /etc/nginx/ssl/server.crt;
       ssl_certificate_key /etc/nginx/ssl/server.key;

       ssl_session_cache shared:SSL:10m;
       ssl_session_timeout 5m;

       ssl_protocols SSLv2 SSLv3 TLSv1.2;
       ssl_ciphers HIGH:!aNULL:!MD5;
       ssl_prefer_server_ciphers on;

    location / {
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $http_x_real_ip;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
	      proxy_buffering off;
        proxy_pass https://bi_getui_server_https;
    }

}
# gdios.bi.getui.com
server {
    listen 80;
    server_name *.xsbi.getui.com *.bi.getui.com;
    client_max_body_size 1500m;
    if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
          set $year $1;
          set $month $2;
          set $day $3;
       }
    access_log /app/nginx_logs/${year}${month}${day}/${http_host}.access.log;

    location / {
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $http_x_real_ip;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
	      proxy_buffering off;
        proxy_pass http://bi_getui_server_http;
    }
}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/vpn-nginx-172.18.63.110/conf.d/1-yunjing.conf 'upstream yunjing_server{
	server 172.18.64.150:5080;
	server 172.18.64.151:5080;
	server 172.18.64.152:5080;
	server 172.18.64.153:5080;
}

server {
    underscores_in_headers on;
    listen 80;
    server_name yj.cloudglab.cn;
    client_max_body_size 1500m;
    if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
          set $year $1;
          set $month $2;
          set $day $3;
       }
    access_log /app/nginx_logs/${year}${month}${day}/${http_host}.access.log;
    
    root /app/nginx_data/www;

    location ~ /yj-video/.*\.mp4$ {
        try_files $uri $uri/= 404;
    }

    location /yj-promote/ {
        alias /app/nginx_data/www;
        expires 7d;
    }
    
    location /chrome/ {
        alias /app/nginx_data/www/chrome/;
    
    }

		location ~* ^/login {
        rewrite ^/ /sms-login redirect;
		}

    location ~ .*\.umd.min.js$ {
        proxy_pass http://yunjing_server;
        add_header Cache-Control no-store;
        add_header Cache-Control no-cache;
        add_header Pragma no-cache;
        add_header Expires 0;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header Host $http_host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
    }
                
    location / {
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $http_x_real_ip;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass http://yunjing_server;
        proxy_read_timeout 95;
        proxy_send_timeout 95;
    }
    
    location /fe/image/appicon/ {
    expires 7d;
    proxy_cache appicon;
    proxy_cache_valid 200 302 3d;
    proxy_cache_valid 400 10m;
    proxy_cache_valid any 1m;
    proxy_pass http://yunjing_server;
    proxy_set_header Host $http_host;
    proxy_set_header X-Real-IP $http_x_real_ip;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
}
}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/vpn-nginx-172.18.63.110/conf.d/10-nyc-web.conf 'upstream nyc-web_server{
	server 172.18.64.150:5080;
	server 172.18.64.151:5080;
	server 172.18.64.152:5080;
	server 172.18.64.153:5080;
}

server {
    listen 80;
    server_name nyc-web.cloudglab.cn;
    client_max_body_size 1500m;
    if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
          set $year $1;
          set $month $2;
          set $day $3;
       }
    access_log /app/nginx_logs/${year}${month}${day}/${http_host}.access.log;

    location / {
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $http_x_real_ip;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
	      proxy_buffering off;
        proxy_pass http://nyc-web_server;
    }
}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/vpn-nginx-172.18.63.110/conf.d/11-spa.conf 'upstream spa_server{
	server 172.18.64.150:5080;
	server 172.18.64.151:5080;
	server 172.18.64.152:5080;
	server 172.18.64.153:5080;
}

server {
    listen 80;
    server_name spa.cloudglab.cn;
    client_max_body_size 1500m;
    if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
          set $year $1;
          set $month $2;
          set $day $3;
       }
    access_log /app/nginx_logs/${year}${month}${day}/${http_host}.access.log;

    location / {       
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $http_x_real_ip;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
	      proxy_buffering off;
        proxy_pass http://spa_server;
    }
}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/vpn-nginx-172.18.63.110/conf.d/12-spa-wz.conf 'upstream spa-wz_server{
	server 172.18.64.150:5080;
	server 172.18.64.151:5080;
	server 172.18.64.152:5080;
	server 172.18.64.153:5080;
}

server {
    listen 80;
    server_name spa-wz.cloudglab.cn;
    client_max_body_size 1500m;
    if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
          set $year $1;
          set $month $2;
          set $day $3;
       }
    access_log /app/nginx_logs/${year}${month}${day}/${http_host}.access.log;

    location / {
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $http_x_real_ip;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
	      proxy_buffering off;
        proxy_pass http://spa-wz_server;
    }
}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/vpn-nginx-172.18.63.110/conf.d/13-spadmin.conf 'upstream spadmin_server{
	server 172.18.64.150:5080;
	server 172.18.64.151:5080;
	server 172.18.64.152:5080;
	server 172.18.64.153:5080;
}

server {
    listen 80;
    server_name spadmin.cloudglab.cn;
    client_max_body_size 1500m;
    if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
          set $year $1;
          set $month $2;
          set $day $3;
       }
    access_log /app/nginx_logs/${year}${month}${day}/${http_host}.access.log;

    location ~ .*\.umd.min.js$ {
        proxy_pass http://spadmin_server;
        add_header Cache-Control no-store;
        add_header Cache-Control no-cache;
        add_header Pragma no-cache;
        add_header Expires 0;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header Host $http_host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
    }

    location / {
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $http_x_real_ip;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
	      proxy_buffering off;
        proxy_pass http://spadmin_server;
    }
}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/vpn-nginx-172.18.63.110/conf.d/14-tk.conf 'upstream tk_server{
	server 172.18.64.150:5080;
	server 172.18.64.151:5080;
	server 172.18.64.152:5080;
	server 172.18.64.153:5080;
}

server {
    listen 80;
    server_name tk.cloudglab.cn;
    client_max_body_size 1500m;
    if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
          set $year $1;
          set $month $2;
          set $day $3;
       }
    access_log /app/nginx_logs/${year}${month}${day}/${http_host}.access.log;

    location /chrome/{
    alias /app/nginx_data/www/chrome/;
    }

    location / {
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $http_x_real_ip;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
	      proxy_buffering off;
        proxy_pass http://tk_server;
    }
}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/vpn-nginx-172.18.63.110/conf.d/15-ys.conf 'upstream ys_server{
	server 172.18.64.150:5080;
	server 172.18.64.151:5080;
	server 172.18.64.152:5080;
	server 172.18.64.153:5080;
}

server {
    underscores_in_headers on;
    listen 80;
    server_name ys.cloudglab.cn;
    client_max_body_size 1500m;
    if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
          set $year $1;
          set $month $2;
          set $day $3;
       }
    access_log /app/nginx_logs/${year}${month}${day}/${http_host}.access.log;
    
    location ~ .*\.umd.min.js$ {
        proxy_pass http://ys_server;
        add_header Cache-Control no-store;
        add_header Cache-Control no-cache;
        add_header Pragma no-cache;
        add_header Expires 0;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header Host $http_host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
    }

    location / {
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $http_x_real_ip;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
	      proxy_buffering off;
        proxy_pass http://ys_server;
    }
}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/vpn-nginx-172.18.63.110/conf.d/16-yy.conf 'upstream yy_server{
	server 172.18.64.150:5080;
	server 172.18.64.151:5080;
	server 172.18.64.152:5080;
	server 172.18.64.153:5080;
}

server {
    listen 80;
    server_name yy.cloudglab.cn;
    client_max_body_size 1500m;
    if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
          set $year $1;
          set $month $2;
          set $day $3;
       }
    access_log /app/nginx_logs/${year}${month}${day}/${http_host}.access.log;

    location ~ .*\.umd.min.js$ {
        proxy_pass http://yy_server;
        add_header Cache-Control no-store;
        add_header Cache-Control no-cache;
        add_header Pragma no-cache;
        add_header Expires 0;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header Host $http_host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
    }

    location / {
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $http_x_real_ip;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
	      proxy_buffering off;
        proxy_pass http://yy_server;
    }
}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/vpn-nginx-172.18.63.110/conf.d/17-offlinemap.conf 'server{
    listen 20001;
    server_name 172.18.63.110;
    client_max_body_size 1500m;
    if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
          set $year $1;
          set $month $2;
          set $day $3;
       }
    access_log /app/nginx_logs/${year}${month}${day}/${http_host}.access.log;
   
    location /offlinemap/tools/DrawingManager_min.css {
            rewrite /. https://api.map.baidu.com/library/DrawingManager/1.4/src/DrawingManager_min.css break;
        }

    location /offlinemap/map_load.js {
        rewrite /. https://api.map.baidu.com/api?v=2.0&ak=Gm6QCiE6yQYIT4rMARLTsjGV51fxu1Zi break;
    }

    location /offlinemap/tools/DrawingManager_min.js {
        rewrite /. https://api.map.baidu.com/library/DrawingManager/1.4/src/DrawingManager_min.js break;
    }

    location /offlinemap/tools/Heatmap_min.js {
        rewrite /. https://api.map.baidu.com/library/Heatmap/2.0/src/Heatmap_min.js break;
    }

}
server{
    listen 80;
    server_name offlinemap.cloudglab.xw;
    client_max_body_size 1500m;
    if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
          set $year $1;
          set $month $2;
          set $day $3;
       }
    access_log /app/nginx_logs/${year}${month}${day}/${http_host}.access.log;
   
    location /offlinemap/tools/DrawingManager_min.css {
            rewrite /. https://api.map.baidu.com/library/DrawingManager/1.4/src/DrawingManager_min.css break;
        }

    location /offlinemap/map_load.js {
        rewrite /. https://api.map.baidu.com/api?v=2.0&ak=Gm6QCiE6yQYIT4rMARLTsjGV51fxu1Zi break;
    }

    location /offlinemap/tools/DrawingManager_min.js {
        rewrite /. https://api.map.baidu.com/library/DrawingManager/1.4/src/DrawingManager_min.js break;
    }

    location /offlinemap/tools/Heatmap_min.js {
        rewrite /. https://api.map.baidu.com/library/Heatmap/2.0/src/Heatmap_min.js break;
    }

}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/vpn-nginx-172.18.63.110/conf.d/18-yz.conf 'upstream yz_server{
	server 172.18.64.150:5080;
	server 172.18.64.151:5080;
	server 172.18.64.152:5080;
	server 172.18.64.153:5080;
}

server {
    listen 80;
    server_name yz.cloudglab.cn;
    client_max_body_size 1500m;
    if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
          set $year $1;
          set $month $2;
          set $day $3;
       }
    access_log /app/nginx_logs/${year}${month}${day}/${http_host}.access.log;

    location / {
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $http_x_real_ip;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
	      proxy_buffering off;
        proxy_pass http://yz_server;
    }
}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/vpn-nginx-172.18.63.110/conf.d/19-sms-proxy.conf 'server{
        listen 20002;
        server_name 172.18.63.110;
        client_max_body_size 1500m;
    if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
          set $year $1;
          set $month $2;
          set $day $3;
       }
    access_log /app/nginx_logs/${year}${month}${day}/${http_host}.access.log;

        proxy_ssl_verify off;
        location / {
                proxy_pass https://openapi-smsp.getui.ga.local;
        }

}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/vpn-nginx-172.18.63.110/conf.d/2-bazs.conf 'upstream bazs_server{
	server 172.18.64.150:5080;
	server 172.18.64.151:5080;
	server 172.18.64.152:5080;
	server 172.18.64.153:5080;
}

server {
    underscores_in_headers on;
    listen 80;
    server_name bazs.cloudglab.cn;
    client_max_body_size 1500m;
    if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
          set $year $1;
          set $month $2;
          set $day $3;
       }
    access_log /app/nginx_logs/${year}${month}${day}/${http_host}.access.log;
    

    location /chrome/{
      alias /app/nginx_data/www/chrome/;

    }

    location ~ .*\.umd.min.js$ {
        proxy_pass http://bazs_server;
        add_header Cache-Control no-store;
        add_header Cache-Control no-cache;
        add_header Pragma no-cache;
        add_header Expires 0;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header Host $http_host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
    }

    location / {
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $http_x_real_ip;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
	      proxy_buffering off;
        proxy_pass http://bazs_server;
    }
}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/vpn-nginx-172.18.63.110/conf.d/20-fz-case-manager.conf 'upstream fz-case-manager_server{
	server 172.18.64.150:5080;
	server 172.18.64.151:5080;
	server 172.18.64.152:5080;
	server 172.18.64.153:5080;
}

server {
    listen 80;
    server_name fz-case-manager.cloudglab.cn;
    client_max_body_size 1500m;
    if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
          set $year $1;
          set $month $2;
          set $day $3;
       }
    access_log /app/nginx_logs/${year}${month}${day}/${http_host}.access.log;

    location / {
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $http_x_real_ip;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
	      proxy_buffering off;
        proxy_pass http://fz-case-manager_server;
    }
}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/vpn-nginx-172.18.63.110/conf.d/21-proxy.conf 'upstream cbiz_server{
	server 172.18.64.150:5080;
	server 172.18.64.151:5080;
	server 172.18.64.152:5080;
	server 172.18.64.153:5080;
}

server{
        listen 80;
        underscores_in_headers on;
        server_name cbiz.cloudglab.cn;
        client_max_body_size 1500m;
    if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
          set $year $1;
          set $month $2;
          set $day $3;
       }
    access_log /app/nginx_logs/${year}${month}${day}/${http_host}.access.log;

        location /azproxy/ {
                rewrite ^/azproxy/(.*) /$1 break;
                proxy_pass http://172.18.64.126:39206;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header Host $host;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_http_version 1.1;
                proxy_set_header Connection "";
        }

        location /openapiproxy/ {
                rewrite ^/openapiproxy/(.*) /$1 break;
                proxy_pass http://172.18.64.200:39001;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header Host $host;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_http_version 1.1;
                proxy_set_header Connection "";
        }

        location /azcblooproxy/ {
                rewrite ^/azcblooproxy/(.*) /$1 break;
                proxy_pass http://cbiz_server;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header Host $http_host;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_http_version 1.1;
                proxy_set_header Connection "";
        }

        location /biz_alarm/ {
                rewrite ^/biz_alarm/(.*) /$1 break;
                proxy_pass http://172.18.63.110:9888;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header Host $host;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_http_version 1.1;
                proxy_set_header Connection "";
        }

        location /biz_fence/ {
                rewrite ^/biz_fence/(.*) /$1 break;
                proxy_pass http://172.18.63.110:9888;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header Host $host;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_http_version 1.1;
                proxy_set_header Connection "";
        }

    location /baseproxy/ {
        rewrite ^/baseproxy/(.*) /$1 break;
        proxy_pass http://cbiz_server;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header Host $http_host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
    }
}


upstream orcp_server{
	server 172.18.64.150:5080;
	server 172.18.64.151:5080;
	server 172.18.64.152:5080;
	server 172.18.64.153:5080;
}

server {
    listen 80;
    server_name orcp.cloudglab.cn;
    client_max_body_size 1500M;
    if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
          set $year $1;
          set $month $2;
          set $day $3;
        }
    if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
          set $year $1;
          set $month $2;
          set $day $3;
       }
    access_log /app/nginx_logs/${year}${month}${day}/${http_host}.access.log;
    gzip off;
 
    location / {
        proxy_pass http://orcp_server;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header Host $http_host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
    }
    
    location /orcp_server/ {
        rewrite ^/orcp_server/(.*) /$1 break;
        proxy_pass http://orcp_server;
         
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header Host $http_host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
}
}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/vpn-nginx-172.18.63.110/conf.d/22-apiplat.conf 'upstream apiplat_server{
	server 172.18.64.150:5080;
	server 172.18.64.151:5080;
	server 172.18.64.152:5080;
	server 172.18.64.153:5080;
}

server {
        underscores_in_headers on;
        listen 80;
        server_name apiplat.cloudglab.cn;
        client_max_body_size 1500m;
    if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
          set $year $1;
          set $month $2;
          set $day $3;
       }
    access_log /app/nginx_logs/${year}${month}${day}/${http_host}.access.log;

        location ~ .*\.umd.min.js$ {
                proxy_pass http://apiplat_server;
                add_header Cache-Control no-cache;
                add_header Pragma no-cache;
                add_header Expires 0;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header Host $http_host;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_http_version 1.1;
                proxy_set_header Connection "";
        }
        location / {
                proxy_set_header Host $http_host;
                proxy_set_header X-Real-IP $http_x_real_ip;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_pass http://apiplat_server;
        }
}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/vpn-nginx-172.18.63.110/conf.d/23-clickhouse-client.conf 'server {
    listen 9999;
    server_name ui.tabix.io 172.18.63.110;
    charset        utf-8;
    root /app/nginx_data/www/tabix-18.07.1/build;
    location / {
        if (!-f $request_filename) {
            rewrite ^(.*)$ /index.html last;
        }
        index  index.html index.htm;
    }

}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/vpn-nginx-172.18.63.110/conf.d/24-fz_admin.conf 'upstream fzadmin_server{
	server 172.18.64.150:5080;
	server 172.18.64.151:5080;
	server 172.18.64.152:5080;
	server 172.18.64.153:5080;
}

server {
    underscores_in_headers on;
    listen 80;
    server_name fzadmin.cloudglab.cn;
    client_max_body_size 1500m;
    if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
          set $year $1;
          set $month $2;
          set $day $3;
       }
    access_log /app/nginx_logs/${year}${month}${day}/${http_host}.access.log;
                                
    location ~ /test/api/(fz_app_case|fz_user)/ {
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $http_x_real_ip;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        rewrite /test/(.+) /$1?$args break;
        proxy_pass http://fzadmin_server;
    }
    
    location / {
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $http_x_real_ip;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass http://fzadmin_server;     
    }
}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/vpn-nginx-172.18.63.110/conf.d/25-nyc.conf 'upstream yc_server{
	server 172.18.64.150:5080;
	server 172.18.64.151:5080;
	server 172.18.64.152:5080;
	server 172.18.64.153:5080;
}

server {
    underscores_in_headers on;
    listen 443 ssl;
    ssl_certificate /app/nginx_data/ssl/nyc/cloudglab.com.pem;
    ssl_certificate_key /app/nginx_data/ssl/nyc/cloudglab.com.key;
    server_name yc.cloudglab.cn;
    server_tokens off;
    root /app/nginx_data/www/yjzs/yc_apk_download;
    if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
          set $year $1;
          set $month $2;
          set $day $3;
       }
    access_log /app/nginx_logs/${year}${month}${day}/${http_host}.access.log;

    fastcgi_param HTTPS on;
    fastcgi_param HTTP_SCHEME https;

    location /yuncai_app {
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $http_x_real_ip;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass http://yc_server;
    }

    location /api {
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $http_x_real_ip;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass http://yc_server;
    }

    location /yjzs/apk-download {
         add_header Content-Security-Policy upgrade-insecure-requests;
         alias /app/nginx_data/www/yjzs/yc_apk_download;
         autoindex off;
    }
    
}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/vpn-nginx-172.18.63.110/conf.d/26-qbhs.conf 'upstream qbhs_server{
	server 172.18.64.150:5080;
	server 172.18.64.151:5080;
	server 172.18.64.152:5080;
	server 172.18.64.153:5080;
}

server {
    underscores_in_headers on;
    listen 80;
    server_name qbhs.cloudglab.cn;
    client_max_body_size 200M;
    if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
          set $year $1;
          set $month $2;
          set $day $3;
       }
    access_log /app/nginx_logs/${year}${month}${day}/${http_host}.access.log;
 
    location ~ .*\.umd.min.js$ {
        proxy_pass http://qbhs_server;
        add_header Cache-Control no-store;
        add_header Cache-Control no-cache;
        add_header Pragma no-cache;
        add_header Expires 0;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header Host $http_host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
    }
 
    location / {
        add_header 'Access-Control-Allow-Origin' '*' always;
        add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS, PUT, DELETE';
        add_header 'Access-Control-Allow-Headers' 'DNT,X-Mx-ReqToken,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Authorization';
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $http_x_real_ip;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass http://qbhs_server;
    }
 
    location /api/administrate/user/isOpenPoliceNoLogin {
        add_header 'Access-Control-Allow-Origin' '*' always;
        add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS, PUT, DELETE';
        add_header 'Access-Control-Allow-Headers' 'DNT,X-Mx-ReqToken,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Authorization';
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $http_x_real_ip;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass http://qbhs_server;
    }
 
    location ~ ^/api|app/ {
    set $maintain 0;
        if ($maintain = 1) {
          set $body '{"errno":403}';
          return 200 $body;
    }
        add_header 'Access-Control-Allow-Origin' '*' always;
        add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS, PUT, DELETE';
        add_header 'Access-Control-Allow-Headers' 'DNT,X-Mx-ReqToken,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Authorization';
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $http_x_real_ip;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass http://qbhs_server;
    }
 
    location /get-script.js {
        rewrite /. https://api.map.baidu.com/getscript?v=2.0&ak=Gm6QCiE6yQYIT4rMARLTsjGV51fxu1Zi&services=&t=20210104170446 break;
    }
    location /res {
    add_header Content-Type "application/octet-stream";
    add_header Content-Disposition "attachment;filename=fjm.apk";
    alias /app/nginx_data/www/qbhs/fjm.apk;
    }
}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/vpn-nginx-172.18.63.110/conf.d/27-sandbox.conf 'upstream sandbox_server{
	server 172.18.64.150:5080;
	server 172.18.64.151:5080;
	server 172.18.64.152:5080;
	server 172.18.64.153:5080;
}

server {
    underscores_in_headers on;
    listen 80;
    server_name sandbox.cloudglab.cn;
    client_max_body_size 1500m;
    if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
          set $year $1;
          set $month $2;
          set $day $3;
       }
    access_log /app/nginx_logs/${year}${month}${day}/${http_host}.access.log;
 
 
    location /apkanalyzer_entrance/apk/downloadApk {
        proxy_set_header Host apkanalyzer.cloudglab.cn;
        proxy_set_header X-Real-IP $http_x_real_ip;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass http://sandbox_server;
    }

    location /apkanalyzer_entrance/apk/uploadFtpApk {
        proxy_set_header Host apkanalyzer.cloudglab.cn;
        proxy_set_header X-Real-IP $http_x_real_ip;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass http://sandbox_server;
    }

    location / {
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $http_x_real_ip;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass http://sandbox_server;
    }
 
    location /socket_url {
        rewrite ^/socket_url/(.*)$ /$1 break;
        proxy_pass http://172.18.65.102:8070;
        proxy_redirect off;
        proxy_set_header X-Real_IP $remote_addr;
        proxy_set_header X-Forwarded-For $remote_addr:$remote_port;
        proxy_http_version 1.1;
        proxy_read_timeout 300;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
}
}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/vpn-nginx-172.18.63.110/conf.d/28-yjadmin.conf 'upstream yjadmin_server{
	server 172.18.64.150:5080;
	server 172.18.64.151:5080;
	server 172.18.64.152:5080;
	server 172.18.64.153:5080;
}

server {
    underscores_in_headers on;
    listen 80;
    server_name yjadmin.cloudglab.cn;
    client_max_body_size 1500m;
    if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
          set $year $1;
          set $month $2;
          set $day $3;
       }
    access_log /app/nginx_logs/${year}${month}${day}/${http_host}.access.log;
	
    location ~ .*\.umd.min.js$ {
        proxy_pass http://yjadmin_server;
        add_header Cache-Control no-store;
        add_header Cache-Control no-cache;
        add_header Pragma no-cache;
        add_header Expires 0;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header Host $http_host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
    }

    location / {
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $http_x_real_ip;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass http://yjadmin_server;
    }
}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/vpn-nginx-172.18.63.110/conf.d/29-v3_offlinemap.conf 'server{
    listen 20003;
    server_name 172.18.63.110;
    client_max_body_size 1500m;
    if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
          set $year $1;
          set $month $2;
          set $day $3;
       }
    access_log /app/nginx_logs/${year}${month}${day}/${http_host}.access.log;


    location /offlinemap/tools/DrawingManager_min.css {
            rewrite /. https://api.map.baidu.com/library/DrawingManager/1.4/src/DrawingManager_min.css break;
        }

    location /offlinemap/map_load.js {
        rewrite /. https://api.map.baidu.com/api?v=3.0&ak=Gm6QCiE6yQYIT4rMARLTsjGV51fxu1Zi break;
    }

    location /offlinemap/tools/DrawingManager_min.js {
        rewrite /. https://api.map.baidu.com/library/DrawingManager/1.4/src/DrawingManager_min.js break;
    }

    location /offlinemap/tools/Heatmap_min.js {
        rewrite /. https://api.map.baidu.com/library/Heatmap/2.0/src/Heatmap_min.js break;
    }


}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/vpn-nginx-172.18.63.110/conf.d/3-admin.conf 'upstream admin_server{
	server 172.18.64.150:5080;
	server 172.18.64.151:5080;
	server 172.18.64.152:5080;
	server 172.18.64.153:5080;
}

server {
    listen 80;
    server_name admin.cloudglab.cn;
    client_max_body_size 1500m;
    if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
          set $year $1;
          set $month $2;
          set $day $3;
       }
    access_log /app/nginx_logs/${year}${month}${day}/${http_host}.access.log;

    location / {
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $http_x_real_ip;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
	      proxy_buffering off;
        proxy_pass http://admin_server;
    }
}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/vpn-nginx-172.18.63.110/conf.d/30-weave_scope.conf 'upstream weave_scope {
        hash $remote_addr consistent;
        server 10.254.0.88:80;
}

server{
    listen 8088;
    server_name 172.18.63.110;
    client_max_body_size 1500m;
    if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
          set $year $1;
          set $month $2;
          set $day $3;
       }
    access_log /app/nginx_logs/${year}${month}${day}/${http_host}.access.log;

    auth_basic   "登录认证";
    auth_basic_user_file pass_file;

    location / {
            proxy_pass http://weave_scope/;
            proxy_set_header Host $host:$server_port;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
        }

 }'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/vpn-nginx-172.18.63.110/conf.d/31-18099.conf 'upstream map-base_server{
	server 172.18.64.150:5080;
	server 172.18.64.151:5080;
	server 172.18.64.152:5080;
	server 172.18.64.153:5080;
}

server{
        listen 80;
        underscores_in_headers on;
        server_name map-base.cloudglab.cn;
        client_max_body_size 1500m;
    if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
          set $year $1;
          set $month $2;
          set $day $3;
       }
    access_log /app/nginx_logs/${year}${month}${day}/${http_host}.access.log;

        location / {
                proxy_pass http://map-base_server;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header Host $http_host;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_http_version 1.1;
                proxy_set_header Connection "";
        }
}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/vpn-nginx-172.18.63.110/conf.d/32-kuboard.conf 'upstream kuboard_server{
	server 172.18.64.200:32567;
	server 172.18.64.201:32567;
	server 172.18.64.202:32567;
}

server {
    listen 32567;
    server_name 172.18.63.110;
    client_max_body_size 1500m;
    if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
          set $year $1;
          set $month $2;
          set $day $3;
       }
    access_log /app/nginx_logs/${year}${month}${day}/${http_host}.access.log;

      location / {
        proxy_http_version 1.1;
        proxy_pass_header Authorization;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass http://kuboard_server;
      }
      location /k8s-ws/ {
        proxy_pass http://kuboard_server;
        proxy_http_version 1.1;
        proxy_pass_header Authorization;
        proxy_set_header Upgrade "websocket";
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  }
      gzip on;
}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/vpn-nginx-172.18.63.110/conf.d/33-qbhs-db.conf 'upstream qbhsdp_server{
	server 172.18.64.150:5080;
	server 172.18.64.151:5080;
	server 172.18.64.152:5080;
	server 172.18.64.153:5080;
}

server {
    underscores_in_headers on;
    listen 80;
    server_name qbhs-dp.cloudglab.cn;
    client_max_body_size 200M;
    if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
          set $year $1;
          set $month $2;
          set $day $3;
       }
    access_log /app/nginx_logs/${year}${month}${day}/${http_host}.access.log;

    location / {
        add_header 'Access-Control-Allow-Origin' '*' always;
        add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS, PUT, DELETE';
        add_header 'Access-Control-Allow-Headers' 'DNT,X-Mx-ReqToken,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Authorization';
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $http_x_real_ip;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass http://qbhsdp_server;
    }

}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/vpn-nginx-172.18.63.110/conf.d/34-bf.conf 'upstream bf_server{
	server 172.18.64.150:5080;
	server 172.18.64.151:5080;
	server 172.18.64.152:5080;
	server 172.18.64.153:5080;
}

server {
    underscores_in_headers on;
    listen 80;
    server_name bfxw.cloudglab.cn;
    client_max_body_size 1500m;
    if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
          set $year $1;
          set $month $2;
          set $day $3;
       }
    access_log /app/nginx_logs/${year}${month}${day}/${http_host}.access.log;

    location / {
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $http_x_real_ip;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass http://bf_server;
    }

    location /fe/image/appicon/ {
        expires 7d;
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $http_x_real_ip;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_cache appicon;
        proxy_cache_valid 200 302 3d;
        proxy_cache_valid 400 10m;
        proxy_cache_valid any 1m;
        proxy_pass http://bf_server;
    }
}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/vpn-nginx-172.18.63.110/conf.d/35-bdfz.conf 'upstream bdfz_server{
	server 172.18.64.150:5080;
	server 172.18.64.151:5080;
	server 172.18.64.152:5080;
	server 172.18.64.153:5080;
}

server {
    listen 80;
    server_name bdfz.cloudglab.cn;
    client_max_body_size 1500m;
    if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
          set $year $1;
          set $month $2;
          set $day $3;
       }
    access_log /app/nginx_logs/${year}${month}${day}/${http_host}.access.log;


    location / {
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $http_x_real_ip;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
	      proxy_buffering off;
        proxy_pass http://bdfz_server;
    }
}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/vpn-nginx-172.18.63.110/conf.d/36-yt-nginx.conf 'upstream biz_fence{
	server 172.18.64.150:5080;
	server 172.18.64.151:5080;
	server 172.18.64.152:5080;
	server 172.18.64.153:5080;
}

server {
    underscores_in_headers on;
    listen 9888;
    server_name 172.18.63.110;
    client_max_body_size 1500m;
    if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
          set $year $1;
          set $month $2;
          set $day $3;
       }
    access_log /app/nginx_logs/${year}${month}${day}/${http_host}.access.log;

    location / {
        proxy_set_header Host callback-trans.cloudglab.cn;
        proxy_set_header X-Real-IP $http_x_real_ip;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass http://biz_fence;
    }

    location /alarm/msg/addMsg {
        proxy_set_header Host alarm-base.cloudglab.cn;
        proxy_set_header X-Real-IP $http_x_real_ip;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass http://biz_fence;
    }

    location /alarm/alarm/addTask {
        proxy_set_header Host alarm-base.cloudglab.cn;
        proxy_set_header X-Real-IP $http_x_real_ip;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass http://biz_fence;
    }

    location /alarm/crowd/saveCrowdByDtos {
        proxy_set_header Host alarm-base.cloudglab.cn;
        proxy_set_header X-Real-IP $http_x_real_ip;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass http://biz_fence;
    }


    location /fence/fence/create {
        proxy_set_header Host fence-base.cloudglab.cn;
        proxy_set_header X-Real-IP $http_x_real_ip;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass http://biz_fence;
    }

    location /orcpserver {
        proxy_set_header Host orcp.cloudglab.cn;
        proxy_set_header X-Real-IP $http_x_real_ip;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass http://biz_fence;
    } 
}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/vpn-nginx-172.18.63.110/conf.d/37-spa-survey.conf 'upstream spa_survey{
	server 172.18.64.150:5080;
	server 172.18.64.151:5080;
	server 172.18.64.152:5080;
	server 172.18.64.153:5080;
}

server {
    underscores_in_headers on;
    listen 80;
    server_name operation.cloudglab.cn;
    client_max_body_size 1500m;
  
    if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
          set $year $1;
          set $month $2;
          set $day $3;
       }
    access_log /app/nginx_logs/${year}${month}${day}/${http_host}.access.log;
    
    location ~ /api/survey_manage/bff_survey/(getByToken|submitFromExternal) {
        rewrite /api/(.*) /$1 break;
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $http_x_real_ip;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass http://spa_survey;
    }

    location /survey {
        rewrite /survey/(.*) /$1 break;
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $http_x_real_ip;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass http://spa_survey;
    }

}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/vpn-nginx-172.18.63.110/conf.d/38-yunwei.conf 'server {
    listen 6666;
    server_name 172.18.63.110;
    location ~ /api/datasync/ {
        proxy_pass http://172.18.66.180:9001;
    }
   
    location ~ /api/search/ {
     	proxy_pass http://172.18.65.104:30099;
    }

}

server {
    listen 16666;
    server_name 172.18.63.110;
    location ~ /api/datasync/ {
        proxy_pass http://172.18.66.180:4001;
    }
   
    location ~ /api/search/ {
     	proxy_pass http://172.18.65.104:30099;
    }

}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/vpn-nginx-172.18.63.110/conf.d/4-bazs-case-manager.conf 'upstream bazs-case-manager_server{
	server 172.18.64.150:5080;
	server 172.18.64.151:5080;
	server 172.18.64.152:5080;
	server 172.18.64.153:5080;
}

server {
    underscores_in_headers on;
    listen 80;
    server_name bazs-case-manager.cloudglab.cn;
    client_max_body_size 1500m;
    if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
          set $year $1;
          set $month $2;
          set $day $3;
       }
    access_log /app/nginx_logs/${year}${month}${day}/${http_host}.access.log;

    location /chrome/{
      alias /app/nginx_data/www/chrome/;

    }

    location / {
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $http_x_real_ip;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
	      proxy_buffering off;
        proxy_pass http://bazs-case-manager_server;
    }
}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/vpn-nginx-172.18.63.110/conf.d/42-owncloud.conf 'server {
       listen 443 ssl;
    	server_name owncloud.cloudglab.cn;
    	client_max_body_size 1500m;

    if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
          set $year $1;
          set $month $2;
          set $day $3;
       }
    access_log /app/nginx_logs/${year}${month}${day}/${http_host}.access.log;

       ssl_certificate /etc/nginx/ssl/server.crt;
       ssl_certificate_key /etc/nginx/ssl/server.key;

       ssl_session_cache shared:SSL:10m;
       ssl_session_timeout 5m;

       ssl_protocols SSLv2 SSLv3 TLSv1.2;
       ssl_ciphers HIGH:!aNULL:!MD5;
       ssl_prefer_server_ciphers on;

    location / {
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $http_x_real_ip;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
	      proxy_buffering off;
        proxy_pass http://172.18.64.130:8080;
    }

}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/vpn-nginx-172.18.63.110/conf.d/43-wt-admin.conf 'upstream wt_admin_server{
	server 172.18.64.150:5080;
	server 172.18.64.151:5080;
	server 172.18.64.152:5080;
	server 172.18.64.153:5080;
}

server {
    underscores_in_headers on;
    listen 80;
    server_name xjadmin.cloudglab.cn;
    client_max_body_size 1500m;
    if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
          set $year $1;
          set $month $2;
          set $day $3;
       }
    access_log /app/nginx_logs/${year}${month}${day}/${http_host}.access.log;

    location / {
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $http_x_real_ip;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass http://wt_admin_server;
    }
}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/vpn-nginx-172.18.63.110/conf.d/44-cbiz-model.conf 'upstream cbiz2_server{
	server 172.18.64.150:5080;
	server 172.18.64.151:5080;
	server 172.18.64.152:5080;
	server 172.18.64.153:5080;
}

server {
    listen 80;
    server_name cbiz2.cloudglab.cn;
    client_max_body_size 1500m;
    if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
          set $year $1;
          set $month $2;
          set $day $3;
       }
    access_log /app/nginx_logs/${year}${month}${day}/${http_host}.access.log;

    location / {
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $http_x_real_ip;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
	      proxy_buffering off;
        proxy_pass http://cbiz2_server;
    }
}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/vpn-nginx-172.18.63.110/conf.d/45-yuntu.conf 'server {
  listen       7003;
  server_name  172.18.63.110;
  client_max_body_size    100m;
  if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
        set $year $1;
        set $month $2;
        set $day $3;
     }
  access_log /app/nginx_logs/${year}${month}${day}/${http_host}.access.log;
  add_header X-Frame-Options SAMEORIGIN;
  add_header X-Content-Type-Options  nosniff always;
  add_header X-XSS-Protection "1; mode=block";
        location /api/user{
                proxy_pass http://172.18.64.109:30111/user;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header Host $host;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
       # location /api/account/ {
         # if ( $request_uri !~* "(login|modifyPassword|logout|getLoginInfo)" )
          #         {
           #                return 401;
            #       }
          # proxy_pass http://172.18.64.109:30099/ad-ms-user-platform/account/;
          # proxy_set_header X-Real-IP $remote_addr;
          # proxy_set_header Host $host;
          # proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        #}
        location /taskApi/ {
            proxy_pass http://172.18.64.109:30111/;
            proxy_set_header X-Real-IP $remote_addr; proxy_set_header Host $host;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
        location /graphSnap/ {
            proxy_pass http://172.18.64.109:30111/graphSnap/;
            proxy_set_header X-Real-IP $remote_addr; proxy_set_header Host $host;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
        location /api/ {
            proxy_pass http://172.18.64.109:30115/;
            proxy_set_header X-Real-IP $remote_addr; proxy_set_header Host $host;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
        location ~ .*\.(js|css|png|jpg|woff|ttf)$ {
             proxy_pass http://172.18.64.109:30113;
        }
        location / {
            proxy_pass http://172.18.64.109:30113;
            index index.html;
            try_files $uri $uri/ /index.html;
            add_header Cache-Control no-store;

            proxy_set_header X-Real-IP $remote_addr;

            proxy_set_header Host $host;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
       # location / {
        #    proxy_pass http://172.18.64.109:30115;
         #   index index.html;
          #  try_files $uri $uri/ /app/neo4j_0730_contain;

           # proxy_set_header X-Real-IP $remote_addr;

            #proxy_set_header Host $host;
           # proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        #}
}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/vpn-nginx-172.18.63.110/conf.d/5-dgp-55suo.conf 'upstream dgp-55suo_server{
	server 172.18.64.150:5080;
	server 172.18.64.151:5080;
	server 172.18.64.152:5080;
	server 172.18.64.153:5080;
}

server {
    listen 80;
    server_name dgp-55suo.cloudglab.cn;
    client_max_body_size 1500m;
    if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
          set $year $1;
          set $month $2;
          set $day $3;
       }
    access_log /app/nginx_logs/${year}${month}${day}/${http_host}.access.log;

    location ~ .*\.umd.min.js$ {
        proxy_pass http://dgp-55suo_server;
        add_header Cache-Control no-store;
        add_header Cache-Control no-cache;
        add_header Pragma no-cache;
        add_header Expires 0;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header Host $http_host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
    }

    location / {
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $http_x_real_ip;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
	      proxy_buffering off;
        proxy_pass http://dgp-55suo_server;
    }
}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/vpn-nginx-172.18.63.110/conf.d/6-fz.conf 'upstream fz_server{
	server 172.18.64.150:5080;
	server 172.18.64.151:5080;
	server 172.18.64.152:5080;
	server 172.18.64.153:5080;
}

server {
    listen 80;
    server_name fz.cloudglab.cn;
    client_max_body_size 1500m;
    if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
          set $year $1;
          set $month $2;
          set $day $3;
       }
    access_log /app/nginx_logs/${year}${month}${day}/${http_host}.access.log;

    location /chrome/{
    alias /app/nginx_data/www/chrome/;
    }

    location ~ .*\.umd.min.js$ {
        proxy_pass http://fz_server;
        add_header Cache-Control no-store;
        add_header Cache-Control no-cache;
        add_header Pragma no-cache;
        add_header Expires 0;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header Host $http_host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
    }

    location / {
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $http_x_real_ip;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
	      proxy_buffering off;
        proxy_pass http://fz_server;
    }
}

server {
    listen 8043;
    server_name fz.cloudglab.cn;
    rewrite ^/(.*) http://fz-case-manager.cloudglab.cn/$1 permanent;
}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/vpn-nginx-172.18.63.110/conf.d/7-fz-visit.conf 'upstream fz-visit_server{
	server 172.18.64.150:5080;
	server 172.18.64.151:5080;
	server 172.18.64.152:5080;
	server 172.18.64.153:5080;
}

server {
    listen 80;
    server_name fz-visit.cloudglab.cn;
    client_max_body_size 1500m;
    if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
          set $year $1;
          set $month $2;
          set $day $3;
       }
    access_log /app/nginx_logs/${year}${month}${day}/${http_host}.access.log;

    location / {
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $http_x_real_ip;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
	      proxy_buffering off;
        proxy_pass http://fz-visit_server;
    }
}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/vpn-nginx-172.18.63.110/conf.d/8-jwsp.conf 'upstream jwsp_server{
	server 172.18.64.150:5080;
	server 172.18.64.151:5080;
	server 172.18.64.152:5080;
	server 172.18.64.153:5080;
}

server {
    listen 80;
    server_name jwsp.cloudglab.cn;
    client_max_body_size 1500m;
    if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
          set $year $1;
          set $month $2;
          set $day $3;
       }
    access_log /app/nginx_logs/${year}${month}${day}/${http_host}.access.log;

    location ~ .*\.umd.min.js$ {
        proxy_pass http://jwsp_server;
        add_header Cache-Control no-store;
        add_header Cache-Control no-cache;
        add_header Pragma no-cache;
        add_header Expires 0;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header Host $http_host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
    }

    location / {
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $http_x_real_ip;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
	      proxy_buffering off;
        proxy_pass http://jwsp_server;
    }

    location /image {
        alias /app/nginx_data/www/jwsp/;
        autoindex on;
    }

}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/vpn-nginx-172.18.63.110/conf.d/8888.conf 'server {
    listen 8888;
    server_name 172.18.63.110;
    client_max_body_size 1500m;
    if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
          set $year $1;
          set $month $2;
          set $day $3;
       }
    access_log /app/nginx_logs/${year}${month}${day}/${http_host}.access.log;

    location / {
        proxy_set_header Host $host;
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $http_x_real_ip;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
	proxy_buffering off;
        proxy_pass http://mirrors.cloudglab.ga.local:8888;
    }
}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/vpn-nginx-172.18.63.110/conf.d/9-nyc-admin.conf 'upstream nyc-admin_server{
	server 172.18.64.150:5080;
	server 172.18.64.151:5080;
	server 172.18.64.152:5080;
	server 172.18.64.153:5080;
}

server {
    listen 80;
    server_name nyc-admin.cloudglab.cn;
    client_max_body_size 1500m;
    if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
          set $year $1;
          set $month $2;
          set $day $3;
       }
    access_log /app/nginx_logs/${year}${month}${day}/${http_host}.access.log;

    location / {
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $http_x_real_ip;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
	      proxy_buffering off;
        proxy_pass http://nyc-admin_server;
    }
}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/vpn-nginx-172.18.63.110/conf.d/999999-ops 'server {
    listen 80;
    server_name ops.cloudglab.cn;
    access_log logs/access.log.$host;
    underscores_in_headers on;

    server_tokens off;

   
    location / {
         alias /app/nginx_data/www/ywpt/dist/;
        
         index index.php index.html index.htm default.php default.htm default.html;
    }
   
    location /basic-api {
      rewrite ^.+basic-api/?(.*)$ /$1 break;
      proxy_set_header Host $host;
    	proxy_set_header X-Real-IP $remote_addr;
    	proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_pass http://172.18.63.110:6666/;
      proxy_redirect default;
      add_header Access-Control-Allow-Origin *;
      add_header Access-Control-Allow-Headers X-Requested-With;
      add_header Access-Control-Allow-Methods GET,POST,OPTIONS;
    
    
    }

}

server {
    listen 80;
    server_name dev.ops.cloudglab.cn;
    access_log logs/access.log.$host;
    underscores_in_headers on;

    server_tokens off;

   
    location / {
         alias /app/nginx_data/www/ywpt/dist/;
        
         index index.php index.html index.htm default.php default.htm default.html;
    }
   
    location /basic-api {
      rewrite ^.+basic-api/?(.*)$ /$1 break;
      proxy_set_header Host $host;
    	proxy_set_header X-Real-IP $remote_addr;
    	proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_pass http://172.18.63.110:16666/;
      proxy_redirect default;
      add_header Access-Control-Allow-Origin *;
      add_header Access-Control-Allow-Headers X-Requested-With;
      add_header Access-Control-Allow-Methods GET,POST,OPTIONS;
    
    
    }

}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/vpn-nginx-172.18.63.110/conf.d/DONG_CHANGE-keepalived-check.conf 'server {
        listen 8080;
        server_name localhost;
        return 200;
}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/vpn-nginx-172.18.63.110/conf.d/admin-old_yj-8096.conf 'server {
    listen 8080;
    server_name yunjing.cloudglab.cn;
    client_max_body_size 1500m;
    if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
          set $year $1;
          set $month $2;
          set $day $3;
       }
    access_log /app/nginx_logs/${year}${month}${day}/${http_host}.access.log;

    location / {
        proxy_set_header Host $host;
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $http_x_real_ip;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
	proxy_buffering off;
        proxy_pass http://172.18.64.122:8096;
    }
}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/vpn-nginx-172.18.63.110/conf.d/baobaocloudglab.conf 'upstream k8s_server{
	server 172.18.64.200:5080;
  server 172.18.64.201:5080;
  server 172.18.64.202:5080;
	server 172.18.64.150:5080;
	server 172.18.64.151:5080;
	server 172.18.64.152:5080;
	server 172.18.64.153:5080;
}

server {
    underscores_in_headers on;
    # 端口待确认
    listen 443 ssl;
    # 证书待处理
    ssl_certificate ssl/7314995__cloudglab.com.pem;
    ssl_certificate_key ssl/7314995__cloudglab.com.key;

    server_name baobao.cloudglab.com;
    server_tokens off;
    if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
       set $year $1;
       set $month $2;
       set $day $3;
    }
    access_log /app/nginx_logs/${year}${month}${day}/${http_host}.access.log;

    fastcgi_param HTTPS on;
    fastcgi_param HTTP_SCHEME https;


    #allow 60.190.217.110;
    #allow 183.134.218.236;
    #deny all;
    client_max_body_size   200m;
  location /oa_cg_bridge/ {
              proxy_pass  http://k8s_server/oa_cg_bridge/;
              proxy_set_header    X-Real-IP   $remote_addr;
              proxy_set_header    Host    oa-cg-bridge.cloudglab.cn;
              proxy_set_header    X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_http_version 1.1;
              proxy_set_header Connection "";
              expires -1;
        }
        location / {
              proxy_pass  https://baobao.getui.com;
              proxy_set_header    X-Real-IP   $remote_addr;
              proxy_set_header    Host    $host;
              proxy_set_header    X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_http_version 1.1;
              proxy_set_header Connection "";
              expires -1;
        }
}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/vpn-nginx-172.18.63.110/conf.d/bi-toolbox.conf 'server {
    listen 8080;
    server_name bi-toolbox.cloudglab.cn;
    client_max_body_size 1500m;
    if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
          set $year $1;
          set $month $2;
          set $day $3;
       }
    access_log /app/nginx_logs/${year}${month}${day}/${http_host}.access.log;

    location / {
        proxy_set_header Host $host;
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $http_x_real_ip;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
	proxy_buffering off;
        proxy_pass http://172.18.25.136:11111;
        index index.htm;
    }
}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/vpn-nginx-172.18.63.110/conf.d/extractive.conf 'upstream extractive_server{
	server 172.18.64.150:5080;
	server 172.18.64.151:5080;
	server 172.18.64.152:5080;
	server 172.18.64.153:5080;
}

server {
    underscores_in_headers on;
    listen 7788;
    server_name extractive.cloudglab.cn;
    client_max_body_size 1500m;
    if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
        set $year $1;
        set $month $2;
        set $day $3;
    }
    access_log /app/nginx_logs/${year}${month}${day}/${http_host}.access.log;
 
    location / {
        proxy_set_header Host extractive.cloudglab.cn;
        proxy_set_header X-Real-IP $http_x_real_ip;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass http://extractive_server;
    }
}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/vpn-nginx-172.18.63.110/conf.d/gt-openapi.conf 'upstream gt_openapi {
	server 172.18.64.140:39001;
	server 172.18.64.141:39001;
  server 172.18.64.145:39001;
}

server {
    underscores_in_headers on;
    listen 39001;
    client_max_body_size 150m;
    if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
          set $year $1;
          set $month $2;
          set $day $3;
       }
    access_log /app/nginx_logs/gt_openapi/${year}${month}${day}/${http_host}.access.log;
 
    location / {
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $http_x_real_ip;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass http://gt_openapi;
    }
}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/vpn-nginx-172.18.63.110/conf.d/hue.conf 'server {
    listen 8080;
    server_name hue.cloudglab.cn;
    client_max_body_size 1500m;
    if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
          set $year $1;
          set $month $2;
          set $day $3;
       }
    access_log /app/nginx_logs/${year}${month}${day}/${http_host}.access.log;

    location / {
        proxy_set_header Host $host;
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $http_x_real_ip;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
	proxy_buffering off;
        proxy_pass http://172.18.64.131:8888;
    }
}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/vpn-nginx-172.18.63.110/conf.d/mz9191.conf 'upstream newmz_server{
	server 172.18.75.2:33080;
	server 172.18.75.3:33080;
  server 172.18.75.4:33080;
}

server {
    underscores_in_headers on;
    listen 9191;
    server_name mz.cloudglab.cn;
    client_max_body_size 1500m;
    if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
          set $year $1;
          set $month $2;
          set $day $3;
       }
    access_log /app/nginx_logs/newbf/${year}${month}${day}mz.access.log;
 
    location / {
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $http_x_real_ip;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass http://newmz_server;
    }

    location /fe/image/appicon/ {
        expires 7d;
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $http_x_real_ip;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_cache appicon;
        proxy_cache_valid 200 302 3d;
        proxy_cache_valid 400 10m;
        proxy_cache_valid any 1m;
        proxy_pass http://newmz_server;
    }
}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/vpn-nginx-172.18.63.110/conf.d/n9e.conf 'server {
    listen 8080;
    server_name n9e.cloudglab.cn;
    client_max_body_size 1500m;
    if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
          set $year $1;
          set $month $2;
          set $day $3;
       }
    access_log /app/nginx_logs/${year}${month}${day}/${http_host}.access.log;

    location / {
        proxy_set_header Host $host;
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $http_x_real_ip;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
	proxy_buffering off;
        proxy_pass http://172.18.66.180:8899;
    }
}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/vpn-nginx-172.18.63.110/conf.d/newbf-9191.conf 'upstream newbf_server{
	server 172.18.75.2:33080;
	server 172.18.75.3:33080;
  server 172.18.75.4:33080;
}

server {
    underscores_in_headers on;
    listen 9191;
    server_name bf.cloudglab.cn;
    client_max_body_size 1500m;
    if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
          set $year $1;
          set $month $2;
          set $day $3;
       }
    access_log /app/nginx_logs/newbf/${year}${month}${day}/${http_host}.access.log;
 
    location / {
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $http_x_real_ip;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass http://newbf_server;
    }

    location /fe/image/appicon/ {
        expires 7d;
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $http_x_real_ip;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_cache appicon;
        proxy_cache_valid 200 302 3d;
        proxy_cache_valid 400 10m;
        proxy_cache_valid any 1m;
        proxy_pass http://newbf_server;
    }
}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/vpn-nginx-172.18.63.110/conf.d/ops-apollo.conf 'server {
    listen 8080;
    server_name ops-apollo.cloudglab.cn;
    client_max_body_size 1500m;
    if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
          set $year $1;
          set $month $2;
          set $day $3;
       }
    access_log /app/nginx_logs/${year}${month}${day}/${http_host}.access.log;

    location / {
        proxy_pass http://172.18.66.80:18070;
    }
}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/vpn-nginx-172.18.63.110/conf.d/shence.conf 'server {
    listen 8080;
    server_name sensors.cloudglab.cn;
    client_max_body_size 1500m;
    if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
          set $year $1;
          set $month $2;
          set $day $3;
       }
    access_log /app/nginx_logs/${year}${month}${day}/${http_host}.access.log;

    location / {
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $host;
        proxy_ignore_client_abort on;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
        proxy_pass http://172.18.71.2:8107;
    }
}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/vpn-nginx-172.18.63.110/conf.d/status.conf 'server {
        listen       8011;
        server_name  localhost;
        location /status {
               vhost_traffic_status_display;
               vhost_traffic_status_display_format html; 
        }
}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/vpn-nginx-172.18.63.110/conf.d/test-8866.conf 'upstream yunjing8866_server{
	server 153.yunjing.cn:5080;
}

server {
    listen 8866;
    client_max_body_size 1500m;
    if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
          set $year $1;
          set $month $2;
          set $day $3;
       }
    access_log /app/nginx_logs/${year}${month}${day}/${http_host}.access.log;

    location / {
        proxy_set_header Host yj.cloudglab.cn;
        proxy_set_header X-Real-IP $http_x_real_ip;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
	      proxy_buffering off;
        proxy_pass http://yunjing8866_server;
    }
}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/vpn-nginx-172.18.63.110/conf.d/xjyypt.conf 'server {
    listen 8080;
    server_name xjyypt.cloudglab.cn;
    client_max_body_size 1500m;
    if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
          set $year $1;
          set $month $2;
          set $day $3;
       }
    access_log /app/nginx_logs/${year}${month}${day}/${http_host}.access.log;

    location / {
        proxy_set_header Host $host;
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $http_x_real_ip;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
				proxy_buffering off;
        proxy_pass http://172.18.64.131:7300;
    }
}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/vpn-nginx-172.18.63.110/conf.d/yapi-777.conf 'server {
    listen 7777;
    server_name 172.18.63.110;
    client_max_body_size 1500m;
    if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
          set $year $1;
          set $month $2;
          set $day $3;
       }
    access_log /app/nginx_logs/${year}${month}${day}/${http_host}.access.log;

    location / {
        proxy_set_header Host $host;
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $http_x_real_ip;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
	proxy_buffering off;
        proxy_pass http://172.18.79.5:7777;
    }
}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/vpn-nginx-172.18.63.110/conf.d/yw.conf 'server {
    listen 8080;
    server_name yw.cloudglab.cn;
    client_max_body_size 1500m;
    if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
          set $year $1;
          set $month $2;
          set $day $3;
       }
    access_log /app/nginx_logs/${year}${month}${day}/${http_host}.access.log;

    location / {
        proxy_set_header Host $host;
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $http_x_real_ip;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
	proxy_buffering off;
        proxy_pass http://172.18.64.123:8198;
    }
}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/vpn-nginx-172.18.63.110/nginx.conf '# For more information on configuration, see:
#   * Official English Documentation: http://nginx.org/en/docs/
#   * Official Russian Documentation: http://nginx.org/ru/docs/

user root;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

# Load dynamic modules. See /usr/share/nginx/README.dynamic.
include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 1024;
}

stream {
      include /etc/nginx/stream/*.conf;
}

http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" $http_host '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile            on;
    client_max_body_size 200m;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 2048;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    # Load modular configuration files from the /etc/nginx/conf.d directory.
    # See http://nginx.org/en/docs/ngx_core_module.html#include
    # for more information.
    include /etc/nginx/conf.d/*.conf;
    
    fastcgi_connect_timeout 1800;
    fastcgi_send_timeout 1800;
    fastcgi_read_timeout 1800;
    fastcgi_buffer_size 128k;
    fastcgi_buffers 8 128k;
    fastcgi_busy_buffers_size 256k;
    fastcgi_temp_file_write_size 256k;
# proxy_buffering off;   #for proxy server
    proxy_buffers 8 32k;   #for proxy server
    proxy_buffer_size 32k;   #for proxy server
    proxy_read_timeout 300s;
    proxy_cache_path /app/nginx_data/cache_appicon levels=1:2 keys_zone=appicon:100m inactive=7d max_size=300m;

    gzip on;
    gzip_min_length  1k;
    gzip_buffers     4 16k;
    gzip_http_version 1.0;
    gzip_comp_level 2;
    gzip_types       text/plain application/x-javascript text/css application/xml;
    gzip_vary on;
    proxy_intercept_errors on;

    vhost_traffic_status_zone;
    vhost_traffic_status_filter_by_host on;
    
}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/vpn-nginx-172.18.63.110/stream/389.conf 'server {
	listen 389;
	proxy_pass ldap_server;
}
upstream ldap_server{
	server 192.168.30.248:389;
}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/vpn-nginx-172.18.63.110/stream/5080.conf 'upstream k8s_server{
	server 172.18.64.200:5080;
  server 172.18.64.201:5080;
  server 172.18.64.202:5080;
	server 172.18.64.150:5080;
	server 172.18.64.151:5080;
	server 172.18.64.152:5080;
	server 172.18.64.153:5080;
}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/vpn-nginx-172.18.63.110/stream/636.conf 'server {
	listen 636;
	proxy_pass ldaps_server;
}
upstream ldaps_server{
	server 192.168.30.248:636;
}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/vpn-nginx-172.18.63.110/stream/7777.conf 'server {
	listen 30200;
	proxy_pass yapi_server;
}
upstream yapi_server{
	server 172.18.79.5:30200;
}
server {
	listen 30580;
	proxy_pass dgovenr_server;
}
upstream dgovenr_server{
	server 172.18.79.5:30580;
}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/vpn-nginx-172.18.63.110/stream/9090.conf 'server {
	listen 9090;
	proxy_pass yjym_server;
}
upstream yjym_server{
	server 172.18.75.2:33080;
	server 172.18.75.3:33080;
        server 172.18.75.4:33080;
}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/xw-nginx-172.18.64.109/ ''
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/xw-nginx-172.18.64.109/conf.d/ ''
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/xw-nginx-172.18.64.109/conf.d/glab_server.conf 'server{
 	listen 9070;
 	server_name 172.18.64.200;
 	client_max_body_size 1500m;
 	access_log logs/admin.log main;

 	location ~ .*\.umd.min.js$ {
 		proxy_pass http://admin_9070;
 		add_header Cache-Control no-store;
 		add_header Cache-Control no-cache;
 		add_header Pragma no-cache;
 		add_header Expires 0;
 		proxy_set_header X-Real-IP $remote_addr;
 		proxy_set_header Host $host;
 		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
 		proxy_http_version 1.1;
 		proxy_set_header Connection "";
 	}
 	location / {
 		proxy_pass http://admin_9070;
 		proxy_set_header X-Real-IP $remote_addr;
 		proxy_set_header Host $host;
 		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
 		proxy_http_version 1.1;
 		proxy_set_header Connection "";
 	}
 }

 server{
 	listen 8040;
 	server_name 172.18.64.200;
 	client_max_body_size 1500m;
 	access_log logs/device_track.log main;

 	location ~ .*\.umd.min.js$ {
 		proxy_pass http://device_track_8040;
 		add_header Cache-Control no-store;
 		add_header Cache-Control no-cache;
 		add_header Pragma no-cache;
 		add_header Expires 0;
 		proxy_set_header X-Real-IP $remote_addr;
 		proxy_set_header Host $host;
 		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
 		proxy_http_version 1.1;
 		proxy_set_header Connection "";
 	}
 	location / {
 		proxy_pass http://device_track_8040;
 		proxy_set_header X-Real-IP $remote_addr;
 		proxy_set_header Host $host;
 		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
 		proxy_http_version 1.1;
 		proxy_set_header Connection "";
 	}
 }

 server{
 	listen 8083;
 	server_name 172.18.64.200;
 	client_max_body_size 1500m;
 	access_log logs/yunshao.log main;

 	location ~ .*\.umd.min.js$ {
 		proxy_pass http://yunshao_8083;
 		add_header Cache-Control no-store;
 		add_header Cache-Control no-cache;
 		add_header Pragma no-cache;
 		add_header Expires 0;
 		proxy_set_header X-Real-IP $remote_addr;
 		proxy_set_header Host $host;
 		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
 		proxy_http_version 1.1;
 		proxy_set_header Connection "";
 	}
 	location / {
 		proxy_pass http://yunshao_8083;
 		proxy_set_header X-Real-IP $remote_addr;
 		proxy_set_header Host $host;
 		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
 		proxy_http_version 1.1;
 		proxy_set_header Connection "";
 	}
 }

 server{
 	listen 8030;
 	server_name 172.18.64.200;
 	client_max_body_size 1500m;
 	access_log logs/yunwang.log main;

 	location ~ .*\.umd.min.js$ {
 		proxy_pass http://yunwang_8030;
 		add_header Cache-Control no-store;
 		add_header Cache-Control no-cache;
 		add_header Pragma no-cache;
 		add_header Expires 0;
 		proxy_set_header X-Real-IP $remote_addr;
 		proxy_set_header Host $host;
 		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
 		proxy_http_version 1.1;
 		proxy_set_header Connection "";
 	}
 	location / {
 		proxy_pass http://yunwang_8030;
 		proxy_set_header X-Real-IP $remote_addr;
 		proxy_set_header Host $host;
 		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
 		proxy_http_version 1.1;
 		proxy_set_header Connection "";
 	}
 }'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/xw-nginx-172.18.64.109/conf.d/v3-offlinemap.conf 'server{
    listen 20003;
    server_name 172.18.64.200;
    client_max_body_size 1500m;
    access_log logs/offline_map.log main;


    location /offlinemap/tools/DrawingManager_min.css {
            rewrite /. https://api.map.baidu.com/library/DrawingManager/1.4/src/DrawingManager_min.css break;
        }

    location /offlinemap/map_load.js {
        rewrite /. https://api.map.baidu.com/api?v=3.0&ak=Gm6QCiE6yQYIT4rMARLTsjGV51fxu1Zi break;
    }

    location /offlinemap/tools/DrawingManager_min.js {
        rewrite /. https://api.map.baidu.com/library/DrawingManager/1.4/src/DrawingManager_min.js break;
    }

    location /offlinemap/tools/Heatmap_min.js {
        rewrite /. https://api.map.baidu.com/library/Heatmap/2.0/src/Heatmap_min.js break;
    }


}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/xw-nginx-172.18.64.109/nginx.conf 'worker_processes 4;
error_log  logs/nginx_error.log  error;
pid        /opt/nginx/nginx.pid;
worker_rlimit_nofile 65535;

events
{
  use epoll;
  worker_connections 65535;
}

http
{
  include       mime.types;
  default_type  application/octet-stream;

  server_names_hash_bucket_size 128;
  client_header_buffer_size 32k;
  large_client_header_buffers 4 32k;
  client_max_body_size 100m;

  sendfile on;
  tcp_nopush     on;
  server_tokens off;

  keepalive_timeout 1800;
  tcp_nodelay on;
  send_timeout 60;

  fastcgi_connect_timeout 1800;
  fastcgi_send_timeout 1800;
  fastcgi_read_timeout 1800;
  fastcgi_buffer_size 128k;
  fastcgi_buffers 8 128k;
  fastcgi_busy_buffers_size 256k;
  fastcgi_temp_file_write_size 256k;
 # proxy_buffering off;   #for proxy server
  proxy_buffers 8 32k;   #for proxy server
  proxy_buffer_size 32k;   #for proxy server
  proxy_read_timeout 300s;
  proxy_cache_path /usr/local/nginx/cache_appicon levels=1:2 keys_zone=appicon:100m inactive=7d max_size=300m;

  gzip on;
  gzip_min_length  1k;
  gzip_buffers     4 16k;
  gzip_http_version 1.0;
  gzip_comp_level 2;
  gzip_types       text/plain application/x-javascript text/css application/xml;
  gzip_vary on;
  proxy_intercept_errors on;

  log_format  main  '$remote_addr - $remote_user [$time_local] $request '
               '$status $body_bytes_sent $http_referer '
               '$http_user_agent $http_x_forwarded_for'
                '$request_uri';
  #access_log on;
  underscores_in_headers on;
  include vhosts/*.conf;
  include upstream/*.conf;
}'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/nginx/xw-nginx-172.18.64.109/stream/ ''
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/squid/ ''
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/squid/squid-172.18.66.129/ ''
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/squid/squid-172.18.66.129/DONT_CHANGE.xw_consul_acl '# 现网consul host
acl xw_consul_port port 8500
acl xw_consul_host dst 172.18.64.200
http_access allow xs_idc xw_consul_host xw_consul_port'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/squid/squid-172.18.66.129/acl.172.18.64.xxx 'acl bazs_port port 8046 8048 8076

acl k8s_host dst 172.18.64.109 172.18.76.126 172.18.64.200 172.18.64.201 172.18.64.202 172.18.76.127 172.18.76.128 172.18.73.120 172.18.73.121 172.18.73.125 172.18.73.128 172.18.74.2 172.18.74.3 172.18.74.4 172.18.74.5 172.18.76.155 172.18.76.185 172.18.76.166 172.18.76.202 172.18.64.142 172.18.64.153 172.18.64.154 172.18.76.195 172.18.76.207 172.18.76.208 172.18.64.153 172.18.64.154
http_access allow bazs_port k8s_host

# neo4j acl 
acl neo4j_port port 7474 7687
acl neo4j_host dst 172.18.64.125
http_access allow neo4j_port neo4j_host

# gboard acl
acl gboard_port port 8080 10002 8090 443
acl gboard_host dst 172.18.64.131
http_access allow gboard_port gboard_host

# loki
acl loki_port port 3100
acl loki_host dst 172.18.64.144
http_access allow xs_idc loki_port loki_host

# qbhs
acl qbhs_port port 9088
acl qbhs_host dst 172.18.64.109
http_access allow xs_idc qbhs_port qbhs_host

# kubeapps1
#acl kubeapps1_port port 20443
#acl kubeapps1_host dst kubeapps1.cloud.svc.dev.local
#http_access allow xs_idc kubeapps1_port kubeapps1_host

acl hbase_test_port port 39007
http_access allow xs_idc hbase_test_port k8s_host


#test usdp
acl usdp_port port 80 3000 9090 9099 16010 16030 8088 50070 7180
acl usdp_host dst 172.18.64.157 172.18.64.158 172.18.64.159
http_access allow xs_idc usdp_port usdp_host

# cg
acl cg_port port 8074 8075 9929
acl cg_host dst 172.18.64.109
http_access allow xs_idc cg_port cg_host

#jwsp
acl jwsp_port port 8123
acl jwsp_host dst 172.18.64.109 172.18.64.200 172.18.64.201 172.18.64.203
http_access allow xs_idc jwsp_port jwsp_host'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/squid/squid-172.18.66.129/acl.172.18.65.xxx '#互联网域consul host
acl online_consul_port port 8500 24481 25849
acl online_consul_host dst 172.18.65.101
http_access allow online_consul_host online_consul_port

acl bazs_ws_port port 8070 32567 30446 25666
acl bazs_ws_host dst 172.18.65.101 172.18.65.102
http_access allow bazs_ws_port bazs_ws_host'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/squid/squid-172.18.66.129/acl.172.18.66.xxx 'acl pve_port port 8006
acl pve_host dst 172.18.66.156
http_access allow pve_port pve_host

acl ops_platform_port port 8080
acl ops_platform_host dst 172.18.66.180
http_access allow ops_platform_port ops_platform_host

acl ops_consul_port port 8500
acl ops_consul_host dst 172.18.66.180
http_access allow ops_consul_port ops_consul_host


acl test-hdp_port port 8080 30009 50070 8088 8188 7080 16010 6080
acl test-hdp_host dst 172.18.66.171 172.18.66.212 172.18.66.200 172.18.66.201 172.18.66.202
http_access allow test-hdp_port test-hdp_host

acl test-usdp_port port 80 3000 9090 9099
acl test-usdp_host dst 172.18.66.202 172.18.66.197
http_access allow test-usdp_port test-usdp_host

acl test-ceph_port port 8443 8000
acl test-ceph_host dst 172.18.66.209 172.18.66.215 172.18.66.216
http_access allow test-ceph_port test-ceph_host

acl test_kubeapps_port port 10443
acl test_kubeapps_host dst kubeapps.cloud.svc.std.local
http_access allow test_kubeapps_port test_kubeapps_host

acl test_consul_host dst consul.cloud.svc.std.local
http_access allow test_kubeapps_port test_consul_host'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/squid/squid-172.18.66.129/acl.172.18.67.xxx 'acl mgapp_api_port port 5000 5555 8081 8000
acl mgapp_api_host dst 172.18.67.32
http_access allow mgapp_api_port mgapp_api_host

acl datanode_jmx_port port 50075 7000
acl datanode_jmx_host dst 172.18.67.74 172.18.67.36
http_access allow datanode_jmx_port datanode_jmx_host

acl dr_elepant_ds_port port 7080
acl dr_elepant_ds_host dst 172.18.67.103
http_access allow dr_elepant_ds_port dr_elepant_ds_host'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/squid/squid-172.18.66.129/acl.172.18.68.xxx '# xw region server acl
acl hbaseregionserver_port port 16030
acl hbaseregionserver_host dst 172.18.68.111 172.18.68.112 172.18.68.113 172.18.68.114 172.18.68.115 172.18.68.116 172.18.68.117 172.18.68.152 172.18.68.153 172.18.68.154 172.18.68.155 172.18.68.156 172.18.68.157 172.18.68.171 172.18.68.172 172.18.68.173 172.18.68.174 172.18.68.175 172.18.68.176 172.18.76.151 172.18.76.153 172.18.76.154 172.18.76.189  172.18.76.190 172.18.76.191 172.18.68.188 172.18.68.189 172.18.68.190 172.18.68.191
http_access allow xs_idc hbaseregionserver_host hbaseregionserver_port

# hbasemaster  acl
acl hbasemaster_port port 16010
acl hbasemaster_host dst 172.18.68.121 172.18.68.122 172.18.76.111 172.18.76.112 172.18.76.150 172.18.76.152 172.18.76.186
http_access allow xs_idc hbasemaster_port hbasemaster_host

# kylo
acl kylo_port port 8400 8079 8080
acl kylo_host dst 172.18.68.151
http_access allow xs_idc kylo_port kylo_host

# canal
acl trust_channel_canal_port port 11111 11112 11110
acl trust_channel_canal_host dst 172.18.68.150
http_access allow xs_idc trust_channel_canal_port trust_channel_canal_host

# dr-elephant
acl dr_elephant_port port 7080
acl dr_elephant_host dst 172.18.68.122 172.18.68.104 172.18.68.11
http_access allow xs_idc dr_elephant_port dr_elephant_host

# spark
acl sparkhistoryserver_port port 18080 18088 18081
acl sparkhistoryserver_host dst  172.18.68.118 172.18.67.103 172.18.68.104 172.18.68.105 172.18.76.110 172.18.68.122 172.18.76.150 172.18.68.11 172.18.68.12
http_access allow xs_idc sparkhistoryserver_port sparkhistoryserver_host'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/squid/squid-172.18.66.129/acl.172.18.74.xxx 'acl new_k8s_host dst 172.18.74.17 172.18.74.19
acl new_k8s_fink_zeppelin_dolphinscheduler port 30007 30008 8881 33081 18181 30019 9999 34081 10002 18882 12345
http_access allow new_k8s_fink_zeppelin_dolphinscheduler new_k8s_host

acl new_develop_host dst 172.18.74.30 172.18.74.31
acl new_develop_port port 8080 50070 8088 10002 80
http_access allow new_develop_port new_develop_host

acl ceph_grafana_host dst 172.18.74.23
acl new_develop_port port 3000 8443
http_access allow new_develop_port ceph_grafana_host

# ranger
acl ranger_host dst 172.18.74.32
acl ranger_port port 6080
http_access allow ranger_port ranger_host

#hbase test
acl ambari_hbase_host dst 172.18.74.129 172.18.74.130 172.18.74.131 172.18.74.132
acl ambari_hbase_port port 8080 50070 16030 16010 8088 8042 19888
http_access allow ambari_hbase_port ambari_hbase_host'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/squid/squid-172.18.66.129/acl.172.18.75.xxx 'acl yjym_k8s_kubeapps_port port 20443 8500 8060 8050 8071 10443
acl yjym_k8s_master_host dst 172.18.75.7 172.18.75.6 172.18.75.5
acl yjym_k8s_host dst 172.18.75.10 172.18.75.7 172.18.75.6 172.18.75.5 kubeapps.cloud.svc.yjym.local kubeapps.cloud.svc.yjym.local consul.cloud.svc.yjym.local
http_access allow xs_idc yjym_k8s_master_host yjym_k8s_kubeapps_port
http_access allow xs_idc yjym_k8s_host yjym_k8s_kubeapps_port'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/squid/squid-172.18.66.129/acl.172.18.76.xxx '# qa2 codis acl
acl sb_qa2_codis_fe_port port 9090 18080
acl sb_qa2_codis_host dst 172.18.76.62 
http_access allow sb_qa2_codis_fe_port sb_qa2_codis_host

# qa2 kubeapps,flink,zeppeline
acl sb_qa2_k8s_host dst 172.18.76.54 172.18.74.17 kubeapps.cloud.svc.qa2.local kubeapps.cloud.svc.qa2.local minio.cloud.svc.qa2.local consul.cloud.svc.qa2.local
acl sb_qa2_kubeapps_port port 10443 8070 35264 8350 19001 30003
acl sb_qa2_flink_port port 8881
acl sb_qa2_zeppelin_port port 30007 30018 30017

#pve 
acl sb_qa2_pve_port port 8006
acl sb_qa2_pve_host dst 172.18.76.23 172.18.76.24 172.18.76.25
http_access allow sb_qa2_pve_port sb_qa2_pve_host

# appllo
acl sb_qa2_appllo_port port 8001 8002 8003
acl sb_qa2_appllo_host dst 172.18.76.54
http_access allow sb_qa2_appllo_port sb_qa2_appllo_host

acl sb_qa2_dolphin_port port 30008 30009
acl sb_qa2_sb_port port 13000 8081
http_access allow sb_qa2_kubeapps_port sb_qa2_k8s_host
http_access allow sb_qa2_flink_port sb_qa2_k8s_host
http_access allow sb_qa2_zeppelin_port sb_qa2_k8s_host
http_access allow sb_qa2_dolphin_port sb_qa2_k8s_host
http_access allow sb_qa2_sb_port sb_qa2_k8s_host


# xxxxxxxxx
acl zeppelin_port port 9995
acl zeppelin_host dst 172.18.76.191
http_access allow zeppelin_port  zeppelin_host


# qa2 apisix acl
acl sb_qa2_apisix_port port 18181 22903 9000 7777 30580 30083 30089
acl sb_qa2_apisix_host dst 172.18.76.54
http_access allow sb_qa2_apisix_port  sb_qa2_apisix_host

# yarn
acl sb_qa2_yarn_port port 8088 50070 8042 19888 45454
acl sb_qa2_yarn_host dst 172.18.76.186 172.18.76.189 172.18.76.190 172.18.76.191 sb-kerberos-hadoop-xs1
http_access allow sb_qa2_yarn_port  sb_qa2_yarn_host

acl sb_qa2_gdios_port port 33631 15924
acl sb_qa2_gdios_host dst 172.18.76.54
http_access allow sb_qa2_gdios_port sb_qa2_gdios_host

acl prometheus_test_port port 9090
acl prometheus_test_host dst 172.18.76.178
http_access allow prometheus_test_port prometheus_test_host

acl gdios_app_port port 10443
acl gdios_app_host dst gdios.cloud.svc.qa2.local dgovern.cloud.svc.qa2.local gdmodeling.cloud.svc.qa2.local ddp.cloud.svc.qa2.local gapi.cloud.svc.qa2.local
http_access allow gdios_app_port gdios_app_host'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/squid/squid-172.18.66.129/all-conf 'acl my_test_k8s_port port 50070 50075 16010 16030 8088 8188 19888
acl my_test_harbor_port port 31820 443

acl new_k8s_fink_zeppelin_dolphinscheduler port 30007 30008 8881
acl bazs_ws_port port 8070 8848
acl bazs_sandbox port 8188
acl sb_qa2_codis_fe_port port 9090 18080
acl sb_qa2_kubeapps_port port 10443 8070 35264 8350 19001
acl new_kubeapps_port port 10443 8070 19001
acl sb_qa2_flink_port port 8881
acl sb_qa2_zeppelin_port port 30007
acl sb_qa2_dolphin_port port 30008 30009
acl sb_qa2_sb_port port 13000 8081

acl pve_port port 8006
acl opentsdb_port port 4242
acl zeppelin_port port 9995
acl flink_port port 31081 20000 20001 20002 20003 8882 32081
acl datahub_port port 19001
acl bmp_port port 31082
acl gitlab_port port 80 443
acl chaosmesh_port port 30949
acl bazs_port port 8046 8048
acl mgapp_api_port port 5000
acl timelineserver_port port 8188 8886
acl metersphere_port port 38081
acl httpfs_port port 14000
acl neo4j_port port 7474 7687
acl gboard_port port 8080 10002
acl presto_ui_port port 8080
acl loki_port port 3100
acl kylo_port port 8400
acl szxn_port port 8521
acl hue_port port 8888 7300
acl edge_port port 8999
acl ambari_port port 8080 8060 8081
acl rancher_port port 8188
acl bk_port port 80
acl zipkin port 9411
acl gitlab_port port 80 443
acl k8s_dashboard_port port 30006 6443 443 3000 9100 9090 30003 30002 30005 32567 2048 10443 20444
acl k8s_weave_scope_port port 19351 12520 8088


acl bk_domain dstdomain pass.ga-xs-bk.com
acl bk_domain dstdomain yj.cloudglab.cn
acl bk_domain1 dstdomain cmdb.ga-xs-bk.com
acl bk_domain2 dstdomain job.ga-xs-bk.com
acl kubeappstest_ui dstdomain kubeapps.cloud.svc.test.local
acl kubeapps_ui dstdomain kubeapps.cloud.svc.dev.local
acl kubeappsnew_ui dstdomain kubeapps.cloud.svc.new.local
acl consul_ui dstdomain consul.cloud.svc.dev.local
acl consulnew_ui dstdomain consul.cloud.svc.new.local
acl kafka_monitor_port port 8082
acl grafana_port port 3000 30002
acl oob_port port 80 443
acl namenode_port port 50070 8088 5000
acl historyserver_port port 19888
acl nodemanager_port port 8042
acl resourcemanager_port port 8088
acl hbasemaster_port port 16010
acl hbaseregionserver_port port 16030

acl azkaban_port port 9444
acl ranger_port port 6080
acl gtopenapi_port port 30102 7777 8801
acl nginx_vts_port port 20003 9011
acl codis_port port 18087
acl zabbix_port port 8080 10051
acl consul_port port 8500 9411 9070 8071
acl wifi_port port 8081 8070 9081 8060 8010 8083 8084 8030 8072 8058 8057  8059 8050 8222 8998 8096
acl kibana_port port 5601
acl yj_port port 8096
acl wifi3.2_port port 8081
acl yuncai_port port 8051 8052
acl kylo port 8079 8080
acl zxw_eshead_port port 9100 9200
acl zxw_oss_port port 9000
acl haiding_custom_port port 9080 9081 9082 9083 9084 9085
acl yt_port port 8199 9898 8061 7003 7004
acl demo_port port 8098
acl devpi_server_port port 3141 80
acl hiveserver2_webui_port port 10002 10004 8880
acl zeeplin_port port 9411

acl journalnode_port port 8480
acl datanode_port port 50075
acl dolphinscheduler_port port 12345 38041
acl matomo_sb port 9080
acl tj_device port 8040
acl dz_yj port 8096
acl dz_yw port 9096
acl dz_yc port 8098
acl dz_wifi port 7080
acl dz_hd port 9083
acl old_yw port 8198
acl old_yc port 8098
acl kafka_manage_port port 80
acl es_head_dz port 9100
acl open_falcon_port port 8081
acl new_yj_port port 8060 30443
acl nifi_port port 8079 8025 1025 8161
acl grafana_port port 3000
acl ga_datasys port 8080
acl data_yunying port 29060
acl prometheus port 30003 30005 9093 30002 9999
acl zxw_offline_map_port port 20001 8076
acl nginx_vts_exporter_port port 9913
acl gdf_port port 8506 61616
acl ga_gboard_port port 8090
acl harbor_port port 5000
acl tidb_port port 3000
acl tidb_prometheus_port port 9090
acl zxw_git_port port 80
acl operation_platform_port port 8100 7300
acl owncloud_port port 80 443 8080
acl glab_apigate_port port 9000
acl apollo_port port 8070 8080
acl az_manager_port port 39010
acl clickhouse_prometheus_port port 9090
acl clickhouse_spark_port port 8080 8081
acl ck_sparkui_port port 44442 44443 44444 44445 44446 44447 44448 44449 44450 44451
acl n9e_port port 8899 3000
acl presto_port port 8080
acl gdios_port port 7777 8111 7778 8802 30040 30002 30095 30199 30200 5083 30087
acl gdios_port1 port 9444 7474 7687
acl gdios_port2 port 8080 18080 7480
acl yjym_k8s_kubeapps_port port 20443 8500 8060 8050 8071 10443
acl yapi_port port 7777

acl my_test_k8s_host dst 172.18.66.230
acl my_test_harbor_host dst 172.18.66.230 172.18.66.233
acl bazs_ws_host dst 172.18.65.101
acl bazs_host dst 172.18.64.153 172.18.65.154
acl sb_qa2_k8s_host dst 172.18.76.54 172.18.74.17 kubeapps.cloud.svc.qa2.local kubeapps.cloud.svc.qa2.local minio.cloud.svc.qa2.local consul.cloud.svc.qa2.local
acl new_k8s_host dst 172.18.74.17
acl sb_qa2_codis_host dst 172.18.76.62

acl yapi_host dst 172.18.79.5
acl pve_host dst 172.18.66.156 172.18.76.23
acl opentsdb_host dst 172.18.66.103
acl mgapp_api_host dst 172.18.67.32
acl timelineserver_host dst 172.18.67.103 172.18.74.30
acl metersphere_host dst 172.18.76.185
acl neo4j_host dst 172.18.64.125
acl gboard_host dst 172.18.64.131
acl presto_ui_host dst 172.18.64.157
acl loki_host dst 172.18.64.144
acl szxn_host dst 172.18.64.200
acl hue_host dst 172.18.67.32 172.18.76.186 172.18.64.131 172.18.72.121
acl yt_host dst 172.18.76.127 172.18.64.141
acl gitlab_host dst 172.18.66.128 172.18.66.199 172.18.64.157
acl bk_host dst 172.18.66.150 172.18.66.151 172.18.66.152
acl dz_yj_host dst 172.18.64.100
acl dz_yc_host dst 172.18.64.101
acl dz_wifi_host dst 172.18.64.102
acl old_yw_host dst 172.18.64.123
acl old_yc_host dst 172.18.64.124
acl nginx_vts_host dst 172.18.76.126 172.18.76.127 172.18.76.128 172.18.64.200 172.18.64.201 172.18.64.202
acl kafka_manage_server dst 172.18.72.119
acl elasticsearch_head_host dst 172.18.64.106 172.18.69.160
acl prometheus_host dst 172.18.76.126 172.18.76.127 172.18.76.128 172.18.64.200 172.18.64.201 172.18.64.202 172.18.64.203 172.18.64.204 172.18.64.205 172.18.64.206 172.18.64.207 172.18.64.208 172.18.65.129 172.18.64.109
acl nginx_vts_exporter_host dst 172.18.76.126 172.18.64.200 172.18.64.201 172.18.64.202
acl kibana_server dst 172.18.76.121 172.18.64.144
acl new_yj_host dst 172.18.76.126 172.18.64.109
acl nifi_host dst 172.18.68.149 172.18.68.150 172.18.68.151 172.18.76.203
acl zxw_offline_map_host dst 172.18.76.126 172.18.76.185 172.18.76.155
acl flink_k8s_host dst 172.18.76.155 172.18.76.207 172.18.74.17 172.18.76.54
acl datahub_k8s_host dst 172.18.76.155 172.18.76.207
acl zeppelin_host dst 172.18.76.191
acl bmp_k8s_host dst 172.18.76.207
acl ambari_host dst 172.18.68.118 172.18.67.101 172.18.76.110 172.18.76.150 172.18.76.186 172.18.66.148 172.18.76.189 172.18.66.223 172.18.66.240 172.18.74.17 172.18.74.23 172.18.66.171 172.18.66.188 172.18.66.191 172.18.66.193 172.18.66.223 172.18.68.11
acl grafana_host dst 172.18.64.129 172.18.67.103
acl namenode_host dst 172.18.68.121 172.18.68.122 172.18.67.101 172.18.67.102 172.18.76.111 172.18.76.112 172.18.76.150 172.18.76.152 172.18.68.11 172.18.68.12
acl historyserver_host dst 172.18.68.118 172.18.67.103 172.18.68.104-109 172.18.68.122 172.18.76.150 172.18.68.12
acl resourcemanager_host dst 172.18.68.121 172.18.68.122 172.18.67.101 172.18.67.103 172.18.68.118 172.18.76.150 172.18.76.152 172.18.76.189
acl nodemanager_host dst  172.18.67.0/25 172.18.68.0/24 172.18.76.178 172.18.76.179 172.18.76.180 172.18.76.181 172.18.76.182 172.18.76.183
acl hbasemaster_host dst 172.18.68.121 172.18.68.122 172.18.76.111 172.18.76.112 172.18.76.150 172.18.76.152 172.18.76.186 172.18.68.11 172.18.68.12 172.18.67.102
acl hbaseregionserver_host dst 172.18.68.193 172.18.67.38 172.18.68.111 172.18.68.112 172.18.68.113 172.18.68.114 172.18.68.115 172.18.68.116 172.18.68.117 172.18.68.152 172.18.68.153 172.18.68.154 172.18.68.155 172.18.68.156 172.18.68.157 172.18.68.171 172.18.68.172 172.18.68.173 172.18.68.174 172.18.68.175 172.18.68.176 172.18.76.151 172.18.76.153 172.18.76.154 172.18.76.189  172.18.76.190 172.18.76.191 172.18.68.188 172.18.68.189 172.18.68.190 172.18.68.191 172.18.68.13 172.18.68.14 172.18.68.15 172.18.68.16 172.18.68.17 172.18.68.18 172.18.68.19 172.18.68.20 172.18.68.21 172.18.68.22 172.18.68.23 172.18.68.24 172.18.68.25 172.18.68.26 172.18.68.27 172.18.68.28 172.18.68.29 172.18.68.30 172.18.68.31 172.18.68.32 172.18.68.33 172.18.68.34

acl azkaban_host dst 172.18.68.122 172.18.76.112 172.18.76.152 172.18.76.196 172.18.76.193
acl ranger_host dst 172.18.68.118 172.18.67.103 172.18.76.186 172.18.76.189 172.18.66.241 172.18.74.23 172.18.68.11
acl codis_host dst 172.18.70.100 172.18.76.119 172.18.76.162 172.18.76.192 172.18.76.198 172.18.66.207 172.18.66.210
acl zabbix_host dst 172.18.64.129
acl k8s_host dst 172.18.64.109 172.18.76.126 172.18.64.200 172.18.64.201 172.18.64.202 172.18.76.127 172.18.76.128 172.18.73.120 172.18.73.121 172.18.73.125 172.18.73.128 172.18.74.2 172.18.74.3 172.18.74.4 172.18.74.5 172.18.76.155 172.18.76.185 172.18.76.166 172.18.76.202 172.18.64.142 172.18.64.153 172.18.64.154 172.18.76.195 172.18.76.207 172.18.76.208
acl gtopenapi_host dst 172.18.64.109 172.18.64.141
acl yj_host dst 172.18.64.95 172.18.64.122
acl wifi3.2_host dst 172.18.64.108
acl kylo_host dst 172.18.68.151 172.18.76.131
acl zxw_eshead_host dst 172.18.76.121 172.18.64.120 172.18.76.162 172.18.69.160
acl haiding_custom_host dst 172.18.64.102
acl open_falcon_host dst 172.18.69.162 172.18.76.138 172.18.66.130
acl grafana_host dst 172.18.67.79 172.18.76.138 172.18.66.130
acl ga_datasys_host dst 172.18.64.131
acl data_yunying_host dst 172.18.64.131
acl demo_host dst 172.18.64.122
acl devpi_server_host dst 172.18.65.101
acl hiveserver2_for_jm dst 172.18.67.101 172.18.67.103 172.18.74.30
acl gdf_host dst 172.18.68.151 172.18.76.203
acl ga_gboard_host dst 172.18.64.131
acl oob_host dst 172.18.99.254
acl zeeplin_host dst 172.18.64.109
acl journalnode_host dst 172.18.68.121-122 172.18.68.104 172.18.66.101-103
#acl datanode_host dst 172.18.68.104-117 172.18.68.123-166
acl datanode_host dst 172.18.68.104-172.18.68.117 172.18.68.123-166 172.18.68.147
acl zxw_mysql_host dst 172.18.76.184
acl harbor_host dst 172.18.66.155 172.18.66.181 172.18.66.154
acl tidb_host dst 172.18.69.170 172.18.69.146
acl operation_platform_host dst 172.18.64.131
acl owncloud_host dst 172.18.64.130
acl consul_host dst 172.18.65.101
acl httpfs_host dst 172.18.67.101
acl gitlab_host dst 172.18.66.122
acl glab_apigate_host dst 172.18.64.109
acl dolphinscheduler_host dst 172.18.64.157 172.18.76.210
acl apollo_host dst 172.18.65.101
acl zxw_git_host dst 172.18.76.185
acl ops_nginx_host dst 172.18.66.80 172.18.64.153 172.18.64.154 172.18.66.81
acl clickhouse_host dst 172.18.67.89 172.18.67.88 172.18.67.87 172.18.67.86
acl ck_sparkui_host dst 172.18.67.32
acl n9e_host dst 172.18.66.180 172.18.66.181
acl presto_host dst 172.18.67.80
acl gdios_host dst 172.18.78.5 172.18.78.6 172.18.78.7
acl gdios_host1 dst 172.18.78.3 172.18.78.4
acl gdios_host2 dst 172.18.78.8 172.18.78.9
acl yjym_k8s_host dst 172.18.75.10 172.18.75.7 172.18.75.6 172.18.75.5 kubeapps.cloud.svc.yjym.local kubeapps.cloud.svc.yjym.local consul.cloud.svc.yjym.local
acl yjym_k8s_master_host dst 172.18.75.7 172.18.75.6 172.18.75.5

http_access allow yapi_port yapi_host
http_access allow new_k8s_fink_zeppelin_dolphinscheduler new_k8s_host
http_access allow my_test_k8s_port my_test_k8s_host
http_access allow my_test_harbor_port my_test_harbor_host
http_access allow bazs_ws_port bazs_ws_host
http_access allow bazs_port bazs_host
http_access allow sb_qa2_codis_fe_port sb_qa2_codis_host
http_access allow sb_qa2_kubeapps_port sb_qa2_k8s_host
http_access allow new_kubeapps_port new_k8s_host
http_access allow sb_qa2_flink_port sb_qa2_k8s_host
http_access allow sb_qa2_zeppelin_port sb_qa2_k8s_host
http_access allow sb_qa2_dolphin_port sb_qa2_k8s_host
http_access allow sb_qa2_sb_port sb_qa2_k8s_host

http_access allow ops_nginx_host
http_access allow apollo_port apollo_host
http_access allow zeppelin_port  zeppelin_host
http_access allow flink_port  flink_k8s_host
http_access allow datahub_port  datahub_k8s_host
http_access allow bmp_port  bmp_k8s_host
http_access allow dolphinscheduler_port dolphinscheduler_host
http_access allow pve_port pve_host
http_access allow opentsdb_port opentsdb_host
http_access allow gitlab_port gitlab_host
http_access allow chaosmesh_port metersphere_host
http_access allow bazs_port k8s_host
http_access allow mgapp_api_port mgapp_api_host
http_access allow timelineserver_port timelineserver_host
http_access allow metersphere_port metersphere_host
http_access allow httpfs_port httpfs_host
http_access allow gboard_port gboard_host
http_access allow presto_ui_port presto_ui_host
http_access allow az_manager_port k8s_host
http_access allow n9e_port n9e_host
http_access allow xs_idc kylo_port kylo_host
http_access allow xs_idc szxn_port szxn_host
http_access allow xs_idc hue_port hue_host
http_access allow xs_idc loki_port loki_host
http_access allow xs_idc consul_port consul_host
http_access allow xs_idc ambari_port ambari_host
http_access allow xs_idc bk_domain
http_access allow xs_idc kubeapps_ui
http_access allow new_k8s_host kubeappsnew_ui
http_access allow xs_idc kubeappstest_ui
http_access allow xs_idc consul_ui
http_access allow new_k8s_host consulnew_ui
http_access allow xs_idc k8s_weave_scope_port k8s_host
http_access allow xs_idc zipkin k8s_host
http_access allow xs_idc rancher_port k8s_host
#cache_peer 172.18.66.150 parent 80 0 no-query originserver name=fdwww
#
#cache_peer_access fdwww allow bk_domain
#cache_peer_access fdwww allow bk_domain1
#cache_peer_access fdwww allow bk_domain2

http_access allow xs_idc hbaseregionserver_port hbaseregionserver_host
http_access allow xs_idc gitlab_port gitlab_host
http_access allow xs_idc gtopenapi_port gtopenapi_host
http_access allow xs_idc bk_port bk_host
http_access allow xs_idc k8s_dashboard_port k8s_host
http_access allow xs_idc matomo_sb k8s_host
http_access allow xs_idc kafka_manage_port kafka_manage_server
http_access allow xs_idc kibana_port kibana_server
http_access allow xs_idc kibana_port k8s_host
http_access allow xs_idc grafana_port grafana_host
http_access allow xs_idc nginx_vts_port nginx_vts_host
http_access allow xs_idc nginx_vts_exporter_port nginx_vts_exporter_host
http_access allow xs_idc namenode_port namenode_host
http_access allow xs_idc grafana_port k8s_host
http_access allow xs_idc historyserver_port historyserver_host
http_access allow xs_idc nodemanager_port nodemanager_host
http_access allow xs_idc yt_port yt_host
http_access allow xs_idc yt_port k8s_host
http_access allow xs_idc prometheus prometheus_host
http_access allow xs_idc resourcemanager_port resourcemanager_host
http_access allow xs_idc hbasemaster_port hbasemaster_host
http_access allow xs_idc zxw_offline_map_port zxw_offline_map_host
http_access allow xs_idc zxw_oss_port zxw_offline_map_host

http_access allow xs_idc azkaban_port azkaban_host
http_access allow xs_idc ranger_port ranger_host
http_access allow xs_idc codis_port codis_host
http_access allow xs_idc zabbix_port zabbix_host
http_access allow xs_idc wifi_port k8s_host
http_access allow xs_idc consul_port k8s_host
http_access allow xs_idc yj_port yj_host
http_access allow xs_idc wifi3.2_port wifi3.2_host
http_access allow xs_idc yuncai_port k8s_host
http_access allow xs_idc kylo kylo_host
http_access allow xs_idc zxw_eshead_port zxw_eshead_host
http_access allow xs_idc haiding_custom_port haiding_custom_host
http_access allow xs_idc es_head_dz elasticsearch_head_host

http_access allow xs_idc tj_device
http_access allow xs_idc dz_yj dz_yj_host
http_access allow xs_idc dz_yw dz_yj_host
http_access allow xs_idc dz_yc dz_yc_host
http_access allow xs_idc dz_wifi dz_wifi_host
http_access allow xs_idc dz_hd dz_wifi_host
http_access allow xs_idc old_yw_host old_yw_host
http_access allow xs_idc old_yc_host old_yc_host
http_access allow xs_idc open_falcon_host open_falcon_port
http_access allow xs_idc new_yj_host new_yj_port
http_access allow xs_idc nifi_host nifi_port
http_access allow xs_idc grafana_host grafana_port
http_access allow xs_idc ambari_host kafka_monitor_port
http_access allow xs_idc ga_datasys ga_datasys_host
http_access allow xs_idc data_yunying data_yunying_host
http_access allow xs_idc demo_port demo_host
http_access allow xs_idc devpi_server_port devpi_server_host
http_access allow xs_idc hiveserver2_webui_port hiveserver2_for_jm
http_access allow xs_idc gdf_port gdf_host
http_access allow xs_idc ga_gboard_port ga_gboard_host
http_access allow xs_idc oob_port oob_host
http_access allow xs_idc zeeplin_port zeeplin_host
http_access allow xs_idc edge_port k8s_host
http_access allow xs_idc journalnode_port journalnode_host
http_access allow xs_idc datanode_port datanode_host
http_access allow xs_idc harbor_port harbor_host
http_access allow xs_idc tidb_port tidb_host
http_access allow xs_idc tidb_prometheus_port tidb_host
http_access allow xs_idc zxw_git_port zxw_git_host
http_access allow xs_idc operation_platform_port   operation_platform_host
http_access allow xs_idc owncloud_port owncloud_host
http_access allow xs_idc neo4j_port neo4j_host
http_access allow xs_idc glab_apigate_port glab_apigate_host
http_access allow xs_idc clickhouse_prometheus_port clickhouse_host
http_access allow xs_idc clickhouse_spark_port clickhouse_host
http_access allow xs_idc ck_sparkui_port ck_sparkui_host
http_access allow xs_idc presto_port presto_host
http_access allow xs_idc gdios_port gdios_host
http_access allow xs_idc gdios_port1 gdios_host1
http_access allow xs_idc gdios_port2 gdios_host2
http_access allow xs_idc yjym_k8s_host yjym_k8s_kubeapps_port
http_access allow xs_idc yjym_k8s_master_host yjym_k8s_kubeapps_port'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/squid/squid-172.18.66.129/hue_acl 'acl hue_port port 8888 7300
acl hue_host dst 172.18.67.32 172.18.76.186 172.18.64.131 172.18.72.121 172.18.67.119
http_access allow xs_idc hue_port hue_host'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/squid/squid-172.18.66.129/presto_acl '# xxxx
acl presto_port port 8080
acl presto_host dst 172.18.67.80 172.18.64.157
http_access allow presto_port presto_host'
etcdctl --cacert=/etc/etcd/ssl/ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  put /ops/squid/squid-172.18.66.129/spark_historyserver_acl '# sparkhistoryserver acl
acl sparkhistoryserver_port port 18080 18088 18081
acl sparkhistoryserver_host dst  172.18.68.118 172.18.67.103 172.18.68.104 172.18.68.105 172.18.76.110 172.18.68.122 172.18.76.150
http_access allow xs_idc sparkhistoryserver_port sparkhistoryserver_host'
