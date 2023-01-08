# Infraestrutura na aws usando terraform, automatizando a configuração das instâncias ec2 com Ansible e utilizando Jenkins para pipelines

Etapa de criação da rede

1° Utilizando o Terraform, fora criada uma VPC 10.123.0.0/16 -- uma nuvem virtual privada permite que recursos da plataforma sejam alocados numa rede, no caso 10.123.0.0/16.

2° Criado um gateway que permite acesso de entrada e saída das instâncias ec2. Por exemplo, o acesso para a rede externa 0.0.0.0 ou o acesso de entrada para uma porta requisitando acesso a um serviço.

3° Logo em seguida uma tabela de roteamento para que o gateway saiba para onde direcionar as conexões.

4° Dependente do recurso acima, criada uma rota -- que fica salva na tabela de roteamento -- para acesso à internet, utilizado cidr_block 0.0.0.0/0.

5° Subnets pública e privada alocadas na VPC e em zonas de disponibilidade diferentes. A pública gera um IP público para todas instâncias ec2 geradas na mesma, já a privada não pois será usada apenas na rede interna. Além disso, nessa etapa utilizada a função cidrsubnet que permite que as subnets sejam geradas automaticamente. Inclusive qualquer quantidade de subnet pode ser gerada.

6° Grupo de segurança criado que permite acesso às instâncias de IP público nas portas 22, 80, 443, 3000 e 9090 (ssh, http, https, grafana e prometheus respectivamente).

# Etapa de criação da instância ec2

1° Utilizada uma imagem Ubuntu 22.04 aliada a um t2.micro (1gib de memória ram e 1 núcleo de processamento)

2° A instância ec2 pode ser gerada em qualquer quantidade, desde que esteja dentro do limite da subnet na qual fará parte, já que possui um cidr /24, ou seja, 2^8-2 (254) hosts disponíveis para cada subnet.
•	Todas as máquinas geradas já terão a chave privada do administrador para conexão ssh e facilitar a vida do Ansible.
•	Todos os IPs públicos gerados são direcionados para um arquivo.txt de inventário para utilização da etapa a seguir.

# Etapa de automatização de instalação e configuração de serviços nas instâncias geradas utilizando Ansible.

1° Configurado no ansible o arquivo ansible.cfg para facilitar e diminuir os comandos no ansible: arquivo de hosts padrão com todos os IPs gerados. E ativação de um recurso chamado log_retry, ou seja, qualquer erro na hora da provisão o ansible mostrará o IP da máquina que resultou o erro e permitirá que eu possa novamente rodar o comando especificamente na instância que resultou o erro.

2° Nesse projeto foram instalados através do Ansible o serviço de monitoramento grafana e o prometheus. Utilizado loops para criação de diversos diretórios, extração, movimentação e cópia de arquivos, além de envio de templates.j2 para configuração do serviço em questão.

# Jenkins 

1° Jenkins file adicionado, utilizando multi branch pipeline (dev,main). Quando o push é feito pela branch dev há algumas condicionais e validações a serem aceitas durante a pipeline. Se feito pela main, não há validações de etapas.
