import 'dart:async';

import 'package:flutter/material.dart';
import 'package:trace_in_mobile_app/features/traceroute/domain/entities/traceroute_info.dart';
import 'package:trace_in_mobile_app/features/traceroute/domain/usescases/get_traceroute_info_usescase.dart';
import 'package:trace_in_mobile_app/features/traceroute/domain/usescases/params/get_traceroute_info_params.dart';

import '../../../../core/utils/text_field_validators.dart';
import '../../../../dependency_inversion.dart';
import '../../../../presentation/widgets/button/button_widget.dart';
import '../../../../presentation/widgets/form/custom_text_field_widget.dart';
import '../../../../presentation/widgets/info_card_widget.dart';
import '../../../ping/domain/entities/ping_info.dart';
import '../../../ping/domain/usescases/get_ping_info_usescase.dart';
import '../../../ping/domain/usescases/params/get_ping_info_params.dart';
import '../../../ping/presentation/screens/ping_info_results_table.dart';

class TracerouteForm extends StatefulWidget {
  const TracerouteForm({Key? key}) : super(key: key);

  @override
  State<TracerouteForm> createState() => _TracerouteFormState();
}

class _TracerouteFormState extends State<TracerouteForm> {
  late final TextEditingController _hostController;
  late final TextEditingController _numberOfHoublonsController;
  late final TextEditingController _timeOutController;
  late final Protocol _currentProtocolSelected;

  late final GlobalKey<FormState> _formKey;

  late final StreamController<Protocol> _protocolStatusController;

  @override
  void initState() {
    super.initState();

    _currentProtocolSelected = Protocol.icmp;

    _formKey = GlobalKey();
    _protocolStatusController = StreamController.broadcast();

    /// Init TextEdditingController
    _hostController = TextEditingController();
    _numberOfHoublonsController = TextEditingController();
    _timeOutController = TextEditingController();
  }

  @override
  void dispose() {
    _protocolStatusController.close();

    _hostController.dispose();
    _numberOfHoublonsController.dispose();
    _timeOutController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Form(
            key: _formKey,
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Traceroute',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const InfoCardWidget(
                        label:
                            "Le traceroute permet de déterminer l'état du réseau et de divers hôtes étrangers ou simplement permet de verifier l'existence d'une machine sur un reseau"),
                    const SizedBox(
                      height: 25,
                    ),
                    ..._buildListItems()
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildListItems() {
    return [
      CustomTextFieldWidget(
          validator: TextFieldValidators.isHost,
          textEditingController: _hostController,
          label: 'Adresse IP/ Host',
          placeholder: 'Ex: google.com, 172.177.44.5'),
      const SizedBox(
        height: 15,
      ),
      _buildThreeTextField(),
      const SizedBox(
        height: 15,
      ),
      CustomTextFieldWidget(
          validator: TextFieldValidators.isNumber,
          textInputType: TextInputType.number,
          textEditingController: _timeOutController,
          label: 'Temps mort',
          placeholder: 'Temps mort en ms'),
      const SizedBox(
        height: 25,
      ),
      _buildActions()
    ];
  }

  Row _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: ButtonWidget(
            willLoad: false,
            function: _handleReset,
            label: 'Reinitialiser',
            buttonType: ButtonType.grey,
          ),
        ),
        const SizedBox(
          width: 7,
        ),
        Expanded(
          child: ButtonWidget(
            willLoad: true,
            function: _handleTriggerPing,
            label: 'Effectuer',
            buttonType: ButtonType.blue,
          ),
        )
      ],
    );
  }

  Row _buildThreeTextField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 2,
          child: CustomTextFieldWidget(
              validator: TextFieldValidators.isNumber,
              textInputType: TextInputType.number,
              textEditingController: _numberOfHoublonsController,
              label: 'N°. houblons',
              placeholder: 'ex: 30'),
        ),
        const SizedBox(
          width: 5,
        ),
        Expanded(
          flex: 1,
          child: StreamBuilder<Protocol>(
              stream: _protocolStatusController.stream,
              initialData: Protocol.icmp,
              builder: (context, protocol) {
                return CustomTextFieldWidget2(
                    currentProtocolSelected: protocol.data!,
                    label: 'Protocol',
                    onPressed: _handleProtocolChoice);
              }),
        ),
      ],
    );
  }

  void _handleReset() {
    _timeOutController.clear();
  }

  void _handleProtocolChoice(Protocol? protocol) {
    _currentProtocolSelected = protocol!;
  }

  void _handleTriggerPing() async {
    if (_formKey.currentState!.validate()) {
      // Retrieve values
      final _params = GetTracerouteInfoParams(
          protocol: _currentProtocolSelected,
          host: _hostController.text,
          hopsMaxNumber: int.tryParse(_numberOfHoublonsController.text) ?? 5,
          timeOut: int.tryParse(_timeOutController.text) ?? 2000);

      final _result =
          (await getIt.get<GetTracerouteInfoUsescase>().trigger(_params))
              .fold((error) => error, (_tracerouteInfos) => _tracerouteInfos);
      debugPrint(_result.toString());
      if (_result is List<TracerouteInfo>) {
        ///TODO
        // showModalBottomSheet(
        //     context: context,
        //     builder: (_) => PingInfoResultsTable(
        //           pingInfos: _result,
        //         ));
      }
    }
  }
}
