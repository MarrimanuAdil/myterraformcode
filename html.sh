sudo apt update 
sudo apt install nginx -y
sudo apt install unzip -y
wget https://templatemo.com/tm-zip-files-2020/templatemo_597_neural_glass.zip
unzip templatemo_597_neural_glass.zip
sudo cp -r templatemo_597_neural_glass/* /var/www/html