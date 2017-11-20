
use strict;
use warnings;
use Encode;
use utf8;
use DBI;

my $db = 'Ynov';
my $host = 'localhost';
my $username = 'root';
my $password = 'root';
my $port = '';




#Connexion au serveur de base de donnée et creation de la base de donnée;
my $dbh = createDB($host,$port,$username,$password);
$dbh->disconnect();
my $dbh2 = DBI->connect("DBI:mysql:database=$db;host=$host;port=$port",$username, $password,{
	RaiseError => 1,

	}) or die "Connexion impossible";

#Creation de la table T_1
my $sql_tables_creation_query =<<"SQL";
CREATE TABLE IF NOT EXISTS T_1(
id INT AUTO_INCREMENT,
value INT,
PRIMARY KEY (id));
SQL
$dbh2->do($sql_tables_creation_query) or die "impossible de creer la table T_1";
+
my $count = 0;
recursiveExo($dbh2, $count);


$dbh2->disconnect();


sub createDB{
	my ($host, $port, $username, $password) = @_; 
	my $dbh = DBI->connect("DBI:mysql:host=$host;port=$port", $username, $password, {
	RaiseError => 1,

	}) or die "Connexion impossible";
	#Creation de la base Ynov
	my $querydb = $dbh->do("CREATE DATABASE IF NOT EXISTS Ynov;");
	return $dbh;
}
sub checkIfOneThousand{
	my $max_id = 0;
	my $prep = $dbh2->prepare('SELECT MAX(id) as Max_ID FROM T_1');
	$prep->execute();
	while( my $data = $prep->fetchrow_hashref){
		print "\t$data->{Max_ID}";
		if($data->{Max_ID}>=1000){
			return 0;
		}
		else {
			return 1;
		}

	}

}
sub recursiveExo{
		my ($a, $count) = @_;
		#Insert
		for (my $value = 0; $value < 100; $value++) {
			$dbh2->do("INSERT INTO T_1(value) VALUES($value)");#Pourquoi j'ai acces a mon dbh2??
			print "Insert".$value."in T_1... \n";
		}
		my $datestring = localtime();
		$datestring =~ s/\s+//g;

		#Backup
		print "Creating backup...\n";
		system("mysqldump -u root Ynov > /root/backups/".$datestring."-".$count.".sql");
		#Pas besoin de -p pour le password car il est conf dans le /etc/mysql/my.cnf
		print "Backup create in /root/backups...\n";
		#Delete
		print "Deleting data";
		$count+=1;
		#Jusqua 1000 entré
		my $check = checkIfOneThousand();
		$dbh2->do("DELETE FROM T_1");
		if($check == 1){
			recursiveExo($dbh2, $count);
		}
}

<>;