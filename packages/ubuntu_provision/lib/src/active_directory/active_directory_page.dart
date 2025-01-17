import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ubuntu_provision/src/active_directory/active_directory_dialogs.dart';
import 'package:ubuntu_provision/src/active_directory/active_directory_widgets.dart';
import 'package:ubuntu_provision/ubuntu_provision.dart';
import 'package:ubuntu_wizard/ubuntu_wizard.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class ActiveDirectoryPage extends ConsumerStatefulWidget with ProvisioningPage {
  const ActiveDirectoryPage({super.key});

  @override
  Future<bool> load(BuildContext context, WidgetRef ref) {
    return ref.read(activeDirectoryModelProvider).init();
  }

  @override
  ConsumerState<ActiveDirectoryPage> createState() =>
      _ActiveDirectoryPageState();
}

class _ActiveDirectoryPageState extends ConsumerState<ActiveDirectoryPage> {
  @override
  Widget build(BuildContext context) {
    final lang = ActiveDirectoryLocalizations.of(context);
    return WizardPage(
      title: YaruWindowTitleBar(
        title: Text(lang.activeDirectoryTitle),
      ),
      contentPadding: EdgeInsets.zero,
      content: LayoutBuilder(builder: (context, constraints) {
        final fieldWidth = (constraints.maxWidth - kWizardPadding.horizontal) *
            kWizardWidthFraction;
        return ListView(
          padding: kWizardPadding,
          children: [
            DomainNameFormField(fieldWidth: fieldWidth),
            const SizedBox(height: kWizardSpacing),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: OutlinedButton(
                onPressed:
                    ref.read(activeDirectoryModelProvider).pingDomainController,
                child: Text(lang.activeDirectoryTestConnection),
              ),
            ),
            const SizedBox(height: kWizardSpacing),
            AdminNameFormField(fieldWidth: fieldWidth),
            const SizedBox(height: kWizardSpacing),
            PasswordFormField(fieldWidth: fieldWidth),
          ],
        );
      }),
      bottomBar: WizardBar(
        leading: const PreviousWizardButton(),
        trailing: [
          NextWizardButton(
            enabled: ref
                .watch(activeDirectoryModelProvider.select((m) => m.isValid)),
            onNext: () async {
              final model = ref.read(activeDirectoryModelProvider);
              await model.save();
              await model.getJoinResult().then((result) {
                if (mounted &&
                    (result == AdJoinResult.JOIN_ERROR ||
                        result == AdJoinResult.PAM_ERROR)) {
                  showActiveDirectoryErrorDialog(context);
                }
              });
            },
          ),
        ],
      ),
    );
  }
}
