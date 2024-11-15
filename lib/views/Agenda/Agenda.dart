import 'package:barberflutter/models/Cliente.dart';
import 'package:barberflutter/models/Day.dart';
import 'package:barberflutter/models/Prenotazione/Prenoatzione.dart';
import 'package:barberflutter/models/Prenotazione/Servizio.dart';
import 'package:barberflutter/viewmodels/ClientiViewModel.dart';
import 'package:barberflutter/viewmodels/PrenotazioniViewModel.dart';
import 'package:barberflutter/viewmodels/TurniViewModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/Prenotazione/Prenotazione_completa.dart';
import '../../models/Turni.dart';
import '../../repositories/Servizirepository.dart';
import '../../ui/theme.dart';
import '../../viewmodels/CalendarViewModel.dart';
import '../../viewmodels/ServizziViewModel.dart';
import '../Navigation/BottomNavigationBar.dart';

class Agenda extends StatefulWidget {
  @override
  _AgendaViewState createState() => _AgendaViewState();
}

class _AgendaViewState extends State<Agenda> {
  int momentYear = DateTime.now().year;
  int momentMonth = DateTime.now().month;
  bool isLoading = true;
  Map<DateTime, DayModel> dayDataMap = {}; // Mappa per salvare i dati di ogni giorno

  List<String> daysOfWeek = [
    "Lunedì", "Martedì", "Mercoledì", "Giovedì", "Venerdì", "Sabato", "Domenica"
  ];

  @override
  void initState() {
    super.initState();
    loadCalendar(); // Carica il calendario e i dati per ogni giorno
  }

  String getMonthName(int month) {
    List<String> months = [
      "Gennaio", "Febbraio", "Marzo", "Aprile", "Maggio", "Giugno",
      "Luglio", "Agosto", "Settembre", "Ottobre", "Novembre", "Dicembre"
    ];
    return months[month - 1];
  }

  Future<void> loadCalendar() async {
    setState(() {
      isLoading = true; // Imposta lo stato di caricamento su vero
    });

    final calendarViewModel = Provider.of<CalendarViewModel>(context, listen: false);
    final prenotazioneViewModel = Provider.of<PrenotazioniViewModel>(context, listen: false);
    String uid = FirebaseAuth.instance.currentUser!.uid;
    // Aggiorna il calendario per l'anno e il mese corrente
    await calendarViewModel.updateCalendar(momentYear, momentMonth);
    await prenotazioneViewModel.checkStorico(uid);
    final calendar = calendarViewModel.calendar;


    // Crea una lista di Future per caricare i dati di ogni giorno
    List<Future<void>> dayFutures = calendar.map((data) async {
      if (data != null && (data.isAfter(DateTime.now()) || _isSameDay(data, DateTime.now()))) {
        DayModel? day = await prenotazioneViewModel.getDay(uid, data);
        if (day != null) {
          dayDataMap[data] = day; // Salva il giorno caricato nella mappa
        }
      }
    }).toList();

    await Future.wait(dayFutures);
    
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double appBarHeight = kToolbarHeight;
    double bottomNavHeight = kBottomNavigationBarHeight;
    double daysOfWeekHeight = 50.0;

    // Altezza totale disponibile per la griglia (6 righe)
    double availableHeight = screenHeight - appBarHeight - bottomNavHeight - daysOfWeekHeight;

    final calendarViewModel = Provider.of<CalendarViewModel>(context);
    final calendar = calendarViewModel.calendar;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.blackBackground,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                setState(() {
                  if (momentMonth == 1) {
                    momentMonth = 12;
                    momentYear--;
                  } else {
                    momentMonth--;
                  }
                  loadCalendar();
                });
              },
            ),
            Text(
              "${getMonthName(momentMonth)} $momentYear",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            IconButton(
              icon: Icon(Icons.arrow_forward, color: Colors.white),
              onPressed: () {
                setState(() {
                  if (momentMonth == 12) {
                    momentMonth = 1;
                    momentYear++;
                  } else {
                    momentMonth++;
                  }
                  loadCalendar();
                });
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomBar(currentIndex: 1),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.blue),
        )
            : Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: daysOfWeek.map((day) {
                  return Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            Expanded(
              child: Column(
                children: List.generate(6, (rowIndex) {
                  return Expanded(
                    child: Row(
                      children: List.generate(7, (colIndex) {
                        int cellIndex = rowIndex * 7 + colIndex;
                        DateTime? data = calendar[cellIndex];
                        if (data != null) {
                          bool isdaycheck = (data.isAfter(DateTime.now()) || _isSameDay(data, DateTime.now())) &&
                              data.month == momentMonth &&
                              data.year == momentYear;
                          bool isToday = _isSameDay(data, DateTime.now());
                          bool isFull = dayDataMap[data]?.full ?? false;

                          return Expanded(
                            child: Container(
                              height: availableHeight / 6, // Altezza dinamica in base alle righe
                              child: isdaycheck
                                  ? Casella(
                                date: data,
                                isToday: isToday,
                                boxHeight: availableHeight / 6,
                                isFull: isFull,
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => PrenotazioniDialog(date: data,onUpdate: loadCalendar),
                                  );
                                },
                              )
                                  : CasellaN(
                                date: data,
                                boxHeight: availableHeight / 6,
                              ),
                            ),
                          );
                        } else {
                          return Expanded(child: SizedBox.shrink());
                        }
                      }),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

class CasellaN extends StatelessWidget {
  final DateTime date;
  final double boxHeight;

  CasellaN({
    required this.date,
    required this.boxHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: boxHeight,
      decoration: BoxDecoration(
        color: AppColors.blackCasellaN,
        border: Border.all(color: AppColors.grayGrigliaN,width:0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(7),
        child: Align(
          alignment: Alignment.topRight,
          child: Text(
            "${date.day}",
            style: TextStyle(
              height: 1.0,
              color: AppColors.grayText,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class Casella extends StatelessWidget {
  final DateTime date;
  final bool isToday;
  final double boxHeight;
  final bool isFull;
  final Function onTap;

  Casella({
    required this.date,
    this.isToday = false,
    required this.boxHeight,
    required this.isFull,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Container(
        height: boxHeight,
        decoration: BoxDecoration(
          color: isToday ? AppColors.blueAg : AppColors.blackAgenda,
          border: Border.all(color: AppColors.grayGriglia,width:0.7),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(5),
              child: Align(
                alignment: Alignment.topRight,
                child: Column(
                  children: [
                    Text(
                      "${date.day}",
                      style: TextStyle(
                        height: 1.0,
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isFull ? Colors.red : Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

bool _isSameDay(DateTime date1, DateTime date2) {
  return date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;
}



class PrenotazioniDialog extends StatefulWidget {
  final DateTime date;
  final Future<void> Function() onUpdate;

  PrenotazioniDialog({required this.date, required this.onUpdate});

  @override
  _PrenotazioniDialogState createState() => _PrenotazioniDialogState();
}

class _PrenotazioniDialogState extends State<PrenotazioniDialog> {
  bool isLoading = true;
  String? clientid= null;
  String? servizi= null;
  late PrenotazioniViewModel prenotazioniViewModel;
  late TurniViewModel turniViewModel;

  String formatDateToYYMMDD(DateTime date) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(date);
  }

  @override
  void initState() {
    super.initState();
    prenotazioniViewModel = Provider.of<PrenotazioniViewModel>(context, listen: false);
    turniViewModel = Provider.of<TurniViewModel>(context, listen: false);
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      prenotazioniViewModel.loadPrenotazioniConDettagli(FirebaseAuth.instance.currentUser!.uid, widget.date),
      turniViewModel.loadTurni(FirebaseAuth.instance.currentUser!.uid),
    ]);
    setState(() {
      isLoading = false;
    });
  }

  void _aggiungiPrenotazione(PrenotazioneModel prenotazione) async {
    // Ottieni l'UID dell'utente corrente
    final uid = FirebaseAuth.instance.currentUser!.uid;

    // Chiama la funzione createPrenotazione nel ViewModel e gestisci i callback
    await prenotazioniViewModel.createPrenotazione(
      uid: uid,
      prenotazione: prenotazione,
      onSuccess: () {
        // Ricarica i dati dopo il successo dell'operazione
        _loadData();

      },
      onUpdate: () {
      widget.onUpdate();
        // Esegui eventuali operazioni di aggiornamento specifiche se necessario

      },
    );
  }


  @override
  Widget build(BuildContext context) {
    String formattedDate = formatDateInItalian(widget.date);
    bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    // Calcola le dimensioni basate sull’orientamento
    double widthFactor = isLandscape ? 0.6 : 0.8;
    double heightFactor = isLandscape ? 0.5 : 0.5; // Regola per riempire più in landscape

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
      child: AlertDialog(
        titlePadding: EdgeInsets.only(top: 10, bottom: 10, left: 15),
        contentPadding: EdgeInsets.only(left: 15, right: 15, bottom: 20),
        actionsPadding: EdgeInsets.only(bottom: 0),
        title: Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.blackCasellaN,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: Colors.white),
                  ),
                ),
              ),
            ),
            Text(formattedDate),
            Expanded(child: SizedBox()),
          ],
        ),
        content: ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: Container(
            color: AppColors.blackDialog1,
            child: SizedBox(
              // Larghezza e altezza basate sulle dimensioni e sull'orientamento del dispositivo
              width: MediaQuery.of(context).size.width * widthFactor,
              height: MediaQuery.of(context).size.height * heightFactor,
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _buildPrenotazioniContent(),
            ),
          ),
        ),
        actions: [],
      ),
    );
  }


  Widget _buildPrenotazioniContent() {
    final prenotazioni = prenotazioniViewModel.prenotazioni;
    final prenotazioniPerTurno = <String, List<PrenotazioneCompleta>>{};
    final servizi = Servizirepository();

    for (var prenotazione in prenotazioni) {
      final turnoId = prenotazione.turno.id;
      if (prenotazioniPerTurno.containsKey(turnoId)) {
        prenotazioniPerTurno[turnoId]!.add(prenotazione);
      } else {
        prenotazioniPerTurno[turnoId] = [prenotazione];
      }
    }

    // Ordina i turni prima di passare alla costruzione della ListView
    final sortedTurni = List.from(turniViewModel.turni)
      ..sort((a, b) => a.start.compareTo(b.start));

    return sortedTurni.isNotEmpty
        ? ListView(
      children: sortedTurni.map((turno) {
        final prenotazioniTurno = prenotazioniPerTurno[turno.id] ?? [];
        return Container(
          padding: EdgeInsets.all(8),
          margin: EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "${turno.start}",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: prenotazioniTurno.isNotEmpty
                      ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: prenotazioniTurno.map((prenotazioneCompleta) {
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 4.0),
                        decoration: BoxDecoration(
                          color: AppColors.blackDialog,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                          title: Text(
                            "${prenotazioneCompleta.cliente.nome} ${prenotazioneCompleta.cliente.cognome}",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                          subtitle: FutureBuilder<String>(
                            future: servizi.getServiceName(
                              FirebaseAuth.instance.currentUser!.uid,
                              prenotazioneCompleta.prenotazione.servizioId,
                            ),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Text("Caricamento...");
                              } else if (snapshot.hasError) {
                                return Text("Errore nel caricamento");
                              } else {
                                return Text(snapshot.data ?? "Nome non disponibile");
                              }
                            },
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await prenotazioniViewModel.deletePrenotazione(
                                FirebaseAuth.instance.currentUser!.uid,
                                widget.date,
                                prenotazioneCompleta,
                                    () {
                                  widget.onUpdate();
                                },
                              );
                              _loadData();
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  )
                      : _buildAddPrenotazioneButton(context, widget.date, turno),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    )
        : Center(child: Text("Nessun turno trovato per questa data."));
  }



  Widget _buildAddPrenotazioneButton(BuildContext context,DateTime data,TurnoModel turno) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        color: Colors.blue,
        child: IconButton(
          icon: Icon(Icons.add_circle, color: Colors.white),
          onPressed: () {
            showDialog(
              context: context,
               builder: (context) => PrenotazioneSelectionWidget( data: formatDateToYYMMDD(widget.date),turno:turno ,
              onPrenotazioneAggiunta: (prenotazione) {
                _aggiungiPrenotazione(prenotazione);// Ricarica le prenotazioni dopo l'aggiunta
              },
               )
            );
          },
        ),
      ),
    );

  }


// Funzione di utilità per formattare la data
String formatDateInItalian(DateTime date) {
  int day = date.day;
  String month;

  switch (date.month) {
    case 1:
      month = "gennaio";
      break;
    case 2:
      month = "febbraio";
      break;
    case 3:
      month = "marzo";
      break;
    case 4:
      month = "aprile";
      break;
    case 5:
      month = "maggio";
      break;
    case 6:
      month = "giugno";
      break;
    case 7:
      month = "luglio";
      break;
    case 8:
      month = "agosto";
      break;
    case 9:
      month = "settembre";
      break;
    case 10:
      month = "ottobre";
      break;
    case 11:
      month = "novembre";
      break;
    case 12:
      month = "dicembre";
      break;
    default:
      month = "";
  }

  return "$day $month";
}
}




enum DialogStep { cliente, servizio, riepilogo }

class PrenotazioneSelectionWidget extends StatefulWidget {
  final String data;
  final TurnoModel turno;
  final Function(PrenotazioneModel) onPrenotazioneAggiunta;

  PrenotazioneSelectionWidget({required this.onPrenotazioneAggiunta,required this.turno,required this.data});

  @override
  _PrenotazioneSelectionWidgetState createState() => _PrenotazioneSelectionWidgetState();
}

class _PrenotazioneSelectionWidgetState extends State<PrenotazioneSelectionWidget> {
  ClienteModel? selectedClientId;
  ServizioModel? selectedServiceId;
  DialogStep currentStep = DialogStep.cliente;

  void _setDialogStep(DialogStep step) {
    setState(() {
      currentStep = step;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: EdgeInsets.only(top: 10, bottom: 10, left: 15),
      contentPadding: EdgeInsets.only(left: 15, right: 15, bottom: 20),
      actionsPadding: EdgeInsets.only(bottom: 0),
      title: _buildTitle(),
      content: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: Container(
          color: AppColors.blackDialog1,
          width: (MediaQuery
              .of(context)
              .size
              .width / 3) * 2,
          height: (MediaQuery
              .of(context)
              .size
              .height / 3) * 2,
          child: _buildDialogContent(widget.data, widget.turno),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [Expanded(
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.blackCasellaN,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () {
                if (currentStep == DialogStep.servizio) {
                  _setDialogStep(DialogStep.cliente);
                } else if (currentStep == DialogStep.riepilogo) {
                  _setDialogStep(DialogStep.servizio);
                } else {
                  Navigator.of(context).pop();
                }
              },
              icon: Icon(Icons.keyboard_backspace_rounded, color: Colors.white),
              padding: EdgeInsets.all(0),
              color: AppColors.blackCasellaN,
              iconSize: 36.0,
            ),
          ),
        ),
      ),
        Text(
          currentStep == DialogStep.cliente
              ? "Seleziona Cliente"
              : currentStep == DialogStep.servizio
              ? "Seleziona Servizio"
              : "Riepilogo Prenotazione",
          style: TextStyle(fontWeight: FontWeight.bold),),
        Expanded(child: SizedBox()),

      ],
    );
  }

  Widget _buildDialogContent(String data, TurnoModel turno) {
    switch (currentStep) {
      case DialogStep.cliente:
        return _buildClienteSelection();
      case DialogStep.servizio:
        return _buildServizioSelection();
      case DialogStep.riepilogo:
        return _buildRiepilogoContent(data, turno);
    }
  }

  Widget _buildClienteSelection() {
    final clientiViewModel = Provider.of<ClientiViewModel>(
        context, listen: false);

    return FutureBuilder<void>(
      future: clientiViewModel.getClienti(
          FirebaseAuth.instance.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {

        }

        final clienti = clientiViewModel.clienti;
        return ListView.builder(
          itemCount: clienti.length,
          itemBuilder: (context, index) {
            final cliente = clienti[index];
            return Column(
              children: [
                ListTile(
                  leading: Icon(
                      Icons.account_circle, color: Colors.white, size: 40.0),
                  title: Text("${cliente.nome} ${cliente.cognome}",
                      style: TextStyle(color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                  subtitle: Text(
                      cliente.telefono, style: TextStyle(color: Colors.grey)),
                  onTap: () {
                    setState(() {
                      selectedClientId = cliente;
                      _setDialogStep(DialogStep.servizio);
                    });
                  },
                ),
                if (index <
                    clienti.length - 1) // Divider only if not the last item
                  Divider(
                    color: AppColors.grayGrigliaN, // Adjust color as needed
                    thickness: 0.5,
                    indent: 16.0,
                    endIndent: 16.0,
                  ),
              ],
            );
          },
        );
      },
    );
  }


  Widget _buildServizioSelection() {
    final serviziViewModel = Provider.of<ServiziViewmodel>(
        context, listen: false);

    return FutureBuilder<void>(
      future: serviziViewModel.getServizzi(
          FirebaseAuth.instance.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final servizi = serviziViewModel.servizi;
        return ListView.builder(
          itemCount: servizi.length,
          itemBuilder: (context, index) {
            final servizio = servizi[index];
            return ListTile(
              leading: Icon(Icons.build, color: Colors.white, size: 36.0),
              title: Text(servizio.nome, style: TextStyle(color: Colors.white)),
              subtitle: Text(
                  "${servizio.prezzo} €", style: TextStyle(color: Colors.grey)),
              onTap: () {
                setState(() {
                  selectedServiceId = servizio;
                  _setDialogStep(DialogStep.riepilogo);
                });
              },

            );
          },
        );
      },
    );
  }

  void _confermaPrenotazione(String data, TurnoModel turno) {
    final uuid = Uuid();
    String uniqueId = uuid.v4();
    final nuovaPrenotazione = PrenotazioneModel(
        id: uniqueId,
        // Usare un ID unico
        clienteId: selectedClientId!.id,
        servizioId: selectedServiceId!.id,
        data: data.toString(),
        turno: turno.id
    );

    widget.onPrenotazioneAggiunta(
        nuovaPrenotazione); // Passa l'oggetto Prenotazione
    Navigator.of(context).pop(); // Chiude il dialogo
  }

  Widget _buildRiepilogoContent(String data, TurnoModel turno) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Dettagli Cliente
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.blackDialog,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Cliente:",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "${selectedClientId?.nome ??
                      "Nome non disponibile"} ${selectedClientId?.cognome ??
                      ""}",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                Text(
                  "Telefono: ${selectedClientId?.telefono ?? "Non disponibile"}",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),

          // Dettagli Servizio
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.blackDialog,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Servizio:",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "${selectedServiceId?.nome ?? "Servizio non disponibile"}",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                Text(
                  "Prezzo: ${selectedServiceId?.prezzo ?? "-"} €",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),

          // Dettagli Turno
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.blackDialog,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Turno:",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Data: $data",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                Text(
                  "Orario: ${turno.start} - ${turno.end}",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),

          // Pulsante di conferma (ripristinato come era prima)
          ElevatedButton(
            onPressed: () => _confermaPrenotazione(data, turno),
            child: Text("Conferma Prenotazione"),
          ),
        ],
      ),
    );
  }
}



