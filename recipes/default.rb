# user ojeda ppa rather than the one
# from package manager
# we need python-software-properties
# for add-apt-repository to work

package 'python-software-properties'

bash 'adding stable php5 ppa' do
  user 'root'
  code <<-EOC
    add-apt-repository ppa: ondrej/php5 
    apt-get update
  EOC
end

# install php5-fpm
package "php5-fpm"

# path to php5-fpm ini
php_fpm_config = '/etc/php5/fpm/php.ini'

# added security
# php interpreter will only process the exact file path, much safer alternative
seds = [
	's/^;cgi\.fix_pathinfo\=1/cgi\.fix_pathinfo\=0/g'
]

bash 'php make safer paths' do
	user 'root'
	code <<-EOC 
		#{seds.map { |rx| "sed -i '#{rx}' #{php_fpm_config}" }.join("\n")}
	EOC
end

template "/etc/php5/fpm/php-fpm.conf" do
  owner "root"
  group "root"
  mode "0644"
  source "php5-fpm.conf.erb"
  notifies :run, "execute[restart-php5-fpm]", :immediately
end

template "/etc/php5/fpm/pool.d/www.conf" do
  owner "root"
  group "root"
  mode "0644"
  source "www.conf.erb"
  notifies :run, "execute[restart-php5-fpm]", :immediately
end

execute "restart-php5-fpm" do
  #restart php5-fpm service
  command "/etc/init.d/php5-fpm restart"
  action :nothing
end