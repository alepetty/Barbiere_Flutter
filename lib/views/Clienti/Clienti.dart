import 'package:barberflutter/views/Navigation/BottomNavigationBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../ui/theme.dart';
import '../../viewmodels/ClientiViewModel.dart';

class ClientiPage extends StatefulWidget {
  @override
  _ClientiPageState createState() => _ClientiPageState();
}

class _ClientiPageState extends State<ClientiPage> {
  @override
  void initState() {
    super.initState();
    // Assicurati di chiamare getClienti quando la pagina viene caricata
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      // Carica i clienti solo se l'utente è autenticato
      Provider.of<ClientiViewModel>(context, listen: false).getClienti(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Clienti'),
      ),
      body: Consumer<ClientiViewModel>(
        builder: (context, clientiViewModel, child) {
          // Se i dati non sono ancora caricati
          if (clientiViewModel.clienti.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }

          final clienti = clientiViewModel.clienti;
          if (clienti.isEmpty) {
            return Center(child: Text('Nessun cliente trovato'));
          }

          return ListView.builder(
            itemCount: clienti.length,
            itemBuilder: (context, index) {
              final cliente = clienti[index];
              return ListTile(
                leading: Icon(Icons.account_circle, color: Colors.white, size: 40.0),
                title: Text(
                  "${cliente.nome} ${cliente.cognome}",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
                subtitle: Text(cliente.telefono, style: TextStyle(color: Colors.grey)),
                onTap: () {
                  _showClientDetailsDialog(context, cliente, clientiViewModel);
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: CustomBottomBar(currentIndex: 2),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddClientDialog(context, context.read<ClientiViewModel>());
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _showClientDetailsDialog(BuildContext context, cliente, ClientiViewModel clientiViewModel) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) return;

    // Recupera il numero di prenotazioni e lo storico servizi usando il ViewModel
    clientiViewModel.fetchNumeroPrenotazioni(uid, cliente.id);
    clientiViewModel.fetchStoricoServizi(uid, cliente.id);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,  // Allinea a sinistra il titolo e a destra le icone
            children: [
              Text('Dettagli Cliente',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _showEditClientDialog(context, cliente, clientiViewModel);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await clientiViewModel.deleteClient(cliente.id);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ],
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.6, // Altezza maggiore per includere la lista
            child: Consumer<ClientiViewModel>(
              builder: (context, viewModel, child) {
                final numeroPrenotazioni = viewModel.numeroPrenotazioni;
                final storicoServizi = viewModel.storicoServizi;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nome, Cognome, Telefono con testo bianco
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text("Nome: ${cliente.nome}",
                          style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text("Cognome: ${cliente.cognome}",
                          style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text("Telefono: ${cliente.telefono}",
                          style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                    SizedBox(height: 16),

                    // Divider before "Storico Servizi"
                    Divider(
                      color: Colors.white, // Imposta il colore della linea
                      thickness: 1, // Spessore della linea
                      indent: 0, // Distanza dall'inizio
                      endIndent: 0, // Distanza dalla fine
                    ),
                    SizedBox(height: 8),

                    // Storico Servizi con testo bianco
                    Text("Storico Servizi:",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    SizedBox(height: 8),

                    // Numero di Prenotazioni con testo bianco e bold
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text("Prenotazioni totali: ${numeroPrenotazioni ?? 'Nessun servizio'}",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                    SizedBox(height: 16),

                    Flexible(
                      child: storicoServizi.isEmpty
                          ? Center(child: Text('Nessun servizio trovato.', style: TextStyle(color: Colors.white)))
                          : ListView.builder(
                        itemCount: storicoServizi.length,
                        itemBuilder: (context, index) {
                          final servizio = storicoServizi[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            subtitle: Text("${servizio['nome']}: ${servizio['volte']} volte",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Chiudi', style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }








  void _showEditClientDialog(BuildContext context, cliente, ClientiViewModel clientiViewModel) {
    final TextEditingController nomeController = TextEditingController(text: cliente.nome);
    final TextEditingController cognomeController = TextEditingController(text: cliente.cognome);
    final TextEditingController telefonoController = TextEditingController(text: cliente.telefono);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Modifica Cliente'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: nomeController,
                decoration: InputDecoration(labelText: 'Nome'),
              ),
              TextField(
                controller: cognomeController,
                decoration: InputDecoration(labelText: 'Cognome'),
              ),
              TextField(
                controller: telefonoController,
                decoration: InputDecoration(labelText: 'Telefono'),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Annulla'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Salva'),
              onPressed: () async {
                await clientiViewModel.updateClient(
                  id: cliente.id,
                  nome: nomeController.text,
                  cognome: cognomeController.text,
                  telefono: telefonoController.text,
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showAddClientDialog(BuildContext context, ClientiViewModel clientiViewModel) {
    final TextEditingController nomeController = TextEditingController();
    final TextEditingController cognomeController = TextEditingController();
    final TextEditingController telefonoController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Aggiungi Cliente'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: nomeController,
                decoration: InputDecoration(labelText: 'Nome'),
              ),
              TextField(
                controller: cognomeController,
                decoration: InputDecoration(labelText: 'Cognome'),
              ),
              TextField(
                controller: telefonoController,
                decoration: InputDecoration(labelText: 'Telefono'),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Annulla'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Aggiungi'),
              onPressed: () async {
                User? user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  await clientiViewModel.addClient(
                    uid: user.uid,
                    nome: nomeController.text,
                    cognome: cognomeController.text,
                    telefono: telefonoController.text,
                  );
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}