# Staging Deploy for Platoniq Development

This branch is configured with the sole purpose of publishing [Platoniq Consul's fork](https://github.com/Platoniq/consul) into a demo Staging instance.

## Staging URL

Checkout Platoniq's Consul demo here:

https://decide.platoniq.net

## Deploy methodology

Working branch (for the time being) is `dashboard`. This branch should be the one that collects all the changes made by the Platoniq team (the nice guys of RockAndRor).

To deploy, we use the strategy explained in https://github.com/consul/installer#deploys-with-capistrano

### 1. Setup:

We assume capistrano is installed in the development machine, that the server is properly configure and the developer has SSH access to the staging machine.

The next command should bring you into the server as the user `deploy`:

```bash
~ ssh deploy@decide.platoniq.net
Welcome to Ubuntu 16.04.5 LTS (GNU/Linux 4.4.0-1070-aws x86_64)
...
```

And capistrano should give you something like:
```bash
~ cap -v
Capistrano Version: 3.10.1 (Rake Version: 12.3.1)
```

### 2. Deploy branch:

We use the branch `dashboard-platoniq` to deploy into the staging server. **It is not necessary for this branch to be up to date with the code**. This branch has 3 main files where deployment strategy has been configured (showing relevant changes):

*Config dashboard as the branch to deploy:*

```ruby
# config/deploy/production.rb
...
set :branch, :dashboard
...
```

*Config Platoniq repo:*

```ruby
# config/deploy/production.rb
...
set :repo_url, 'https://github.com/Platoniq/consul.git'
...
```
**_Finally, the file `deploy-secrets.yml` is not tracked by Git, create one with this values if you want to deploy:_**

```yaml
# config/deploy/deploy-secrets.yml
...
production:
  deploy_to: "/home/deploy/consul"
  ssh_port: 22
  server1: "decide.platoniq.net"
  # server2: xxx.xxx.xxx.xxx
  db_server: "localhost"
  user: "deploy"
  server_name: "decide.platoniq.net"
  full_app_name: "consul"
```

### 3. Deploying:

1. Merge featured branch into dashboard:
   ```bash
   git checkout dashboard
   git merge feature/send-ice-cream-on-register --no-ff
   ```
2. Push to Platoniq repository (I assume here that `origin` is platoniq repository, your case may be different):
   ```bash
   git push origin dashboard
   ```
3. Change to `dashboard-platoniq` and deploy:
   ```bash
   git checkout dashboard-platoniq
   cap production deploy
   ```
4. Cross fingers! 🤞🙈

---
Ivan Vergés - 2018<br>
ivan (at) platoniq.net
