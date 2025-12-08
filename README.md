Через scp или другую утилиту можно перебросить файлы на ВМ, или склонировать гит-репозиторий
Далее нужно добавить права на исполнения всех файлов командой 	chmod +x <file>
Далее нужно конвертировать файлы -
 
	#Устанавливаем утилиту для конвертации файлов windows
	apt -y install dos2unix

	#Конвертируем файлы через установленную утилиту
	dos2unix <file>


###1 и 2 задания:
Автоматизированы 2 файла - script_updatepackeges_cruser_and_addrules и script_dissable_passwd

Первый файл(script_updatepackeges_cruser_and_addrules) обновляет пакеты, устанавливает ssh-server, 
добавляет пользователя DevOps с домашним каталогом и командной оболочкой, предоставляет права sudo без пароля, 
генерирует ключи

Второй файл(script_dissable_passwd) отключает авторизацию ssh по паролю и перезапускает службу

Следовать нужно инструкции ниже:
-выполнить скрипт 	bash script_updatepackeges_cruser_and_addrules
-далее нужно поменять пароль пользователю DevOps  	passwd DevOps
---Далее все это нужно повторить на второй машине
-зайти Devops пользователем и перейти в каталог		su - DevOps && cd /home/DevOps/.ssh/
-потом перенести публичный ключ с первой машины на вторую, со второй на первую	    ssh-copy-id DevOps@<ip адрес ВМ>
-exit
-cd 
-следом выполнить файл  	bash script_dissable_passwd

###3 задание:
-скрипт 	bash database

###4 задание:
-скрипт 	bash nginx

###5 задание:
#Настроит доступ к PostgreSQL на сервере А только с сервера Б
-вставить ip сервера в скрипт, для которого открыть доступ и выполнить скрипт на сервере postgres	 	bash accessTOpostgresql
-на сервере nginx установить клиент postgresql		apt -y install postgresql-client
#закроет доступ к nginxна сервере Б с сервера А. - скрипт 	bash prohibition_nginx