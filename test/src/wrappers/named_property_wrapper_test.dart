// ignore_for_file: prefer-match-file-name, prefer_utc_dates

import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:storage_fields/storage_fields.dart';
import 'package:test/test.dart';

// ignore: long-method
void main() {
  final now = DateTime.now();
  final tomorrow = now.add(const Duration(days: 1));

  group('StorageFieldWrapper', () {
    final storageFieldsServiceStub = StorageFieldsServiceStub();
    final dateForwardingField = _DateForwardingField(
      storageFieldsServiceStub,
    );
    final alwaysValidPrimaryFieldWrapper =
        _ConfigurablePrimaryFieldWrapper<String>(
      storageFieldsService: storageFieldsServiceStub,
      fieldCode: 'base_field_always_valid',
      validityParams: PrimaryFieldValidityParams.alwaysValid(),
    );
    final validForDayPrimaryFieldWrapper =
        _ConfigurablePrimaryFieldWrapper<String>(
      storageFieldsService: storageFieldsServiceStub,
      fieldCode: 'base_field_valid_for_day',
      validityParams: PrimaryFieldValidityParams.validForDay(),
    );
    final lastIsValidPrimaryFieldWrapper =
        _ConfigurablePrimaryFieldWrapper<String>(
      storageFieldsService: storageFieldsServiceStub,
      fieldCode: 'base_field_last_is_valid',
      validityParams: PrimaryFieldValidityParams.lastIsValid(),
    );

    setUp(storageFieldsServiceStub.reset);

    group('External data field (custom)', () {
      group('Set', () {
        test('Does nothing', () async {
          await dateForwardingField.set(
            value: DateTime.now().toIso8601String(),
          );

          expect(storageFieldsServiceStub.diagnostics.reads, 0);
          expect(storageFieldsServiceStub.diagnostics.writes, 0);
        });
      });

      group('Get', () {
        test('Returns correct result for different dates', () async {
          final resultForNow = await dateForwardingField.get(date: now);
          expect(
            resultForNow,
            now.toIso8601String(),
            reason: 'Should return now',
          );
          expect(storageFieldsServiceStub.diagnostics.reads, 0);
          expect(storageFieldsServiceStub.diagnostics.writes, 0);

          final resultForTomorrow =
              await dateForwardingField.get(date: tomorrow);
          expect(
            resultForTomorrow,
            tomorrow.toIso8601String(),
            reason: 'Should return tomorrow',
          );

          expect(storageFieldsServiceStub.diagnostics.reads, 0);
          expect(storageFieldsServiceStub.diagnostics.writes, 0);
        });
      });
    });

    group('PrimaryField', () {
      group('Time series', () {
        test('Works correctly, if date is passed', () async {
          await validForDayPrimaryFieldWrapper.set(
            date: now,
            value: 'foo',
          );
          expect(storageFieldsServiceStub.diagnostics.writes, 1);
          expect(storageFieldsServiceStub.diagnostics.reads, 0);

          storageFieldsServiceStub.diagnostics.reset();

          final value = await validForDayPrimaryFieldWrapper.get(date: now);
          expect(value, 'foo');
          expect(storageFieldsServiceStub.diagnostics.writes, 0);
          expect(storageFieldsServiceStub.diagnostics.reads, 1);
        });

        test('Works correctly, if date is not passed', () async {
          await validForDayPrimaryFieldWrapper.set(
            value: 'foo',
          );
          expect(storageFieldsServiceStub.diagnostics.reads, 0);
          expect(storageFieldsServiceStub.diagnostics.writes, 0);

          final value = await validForDayPrimaryFieldWrapper.get();
          expect(value, null);
          expect(storageFieldsServiceStub.diagnostics.reads, 0);
          expect(storageFieldsServiceStub.diagnostics.writes, 0);
        });
      });

      group('Always valid', () {
        test('Works correctly, if date is passed', () async {
          await alwaysValidPrimaryFieldWrapper.set(
            date: now,
            value: 'foo',
          );
          expect(storageFieldsServiceStub.diagnostics.writes, 1);
          expect(storageFieldsServiceStub.diagnostics.reads, 0);

          storageFieldsServiceStub.diagnostics.reset();

          final value = await alwaysValidPrimaryFieldWrapper.get(date: now);
          expect(value, 'foo');
          expect(storageFieldsServiceStub.diagnostics.reads, 1);
          expect(storageFieldsServiceStub.diagnostics.writes, 0);

          storageFieldsServiceStub.diagnostics.reset();

          final valueForTomorrow =
              await alwaysValidPrimaryFieldWrapper.get(date: tomorrow);
          expect(valueForTomorrow, 'foo');
          expect(storageFieldsServiceStub.diagnostics.reads, 1);
          expect(storageFieldsServiceStub.diagnostics.writes, 0);
        });

        test('Works correctly, if date is not passed', () async {
          await alwaysValidPrimaryFieldWrapper.set(
            value: 'foo',
          );
          expect(storageFieldsServiceStub.diagnostics.writes, 1);
          expect(storageFieldsServiceStub.diagnostics.reads, 0);

          storageFieldsServiceStub.diagnostics.reset();

          final value = await alwaysValidPrimaryFieldWrapper.get();
          expect(value, 'foo');
          expect(storageFieldsServiceStub.diagnostics.reads, 1);
          expect(storageFieldsServiceStub.diagnostics.writes, 0);
        });

        test(
          'Works correctly, if date is not passed when set, but passed then get',
          () async {
            await alwaysValidPrimaryFieldWrapper.set(
              value: 'foo',
            );
            expect(storageFieldsServiceStub.diagnostics.writes, 1);
            expect(storageFieldsServiceStub.diagnostics.reads, 0);

            storageFieldsServiceStub.diagnostics.reset();

            final value =
                await alwaysValidPrimaryFieldWrapper.get(date: tomorrow);
            expect(value, 'foo');
            expect(storageFieldsServiceStub.diagnostics.reads, 1);
            expect(storageFieldsServiceStub.diagnostics.writes, 0);
          },
        );
      });

      group('Last is valid', () {
        test('Works correctly, if date is passed', () async {
          await lastIsValidPrimaryFieldWrapper.set(
            date: now,
            value: 'foo',
          );
          expect(storageFieldsServiceStub.diagnostics.writes, 1);
          expect(storageFieldsServiceStub.diagnostics.reads, 0);

          storageFieldsServiceStub.diagnostics.reset();

          final valueForSameDate =
              await lastIsValidPrimaryFieldWrapper.get(date: now);
          expect(valueForSameDate, 'foo');
          expect(storageFieldsServiceStub.diagnostics.reads, 1);
          expect(storageFieldsServiceStub.diagnostics.writes, 0);

          storageFieldsServiceStub.diagnostics.reset();

          final valueForTomorrow =
              await lastIsValidPrimaryFieldWrapper.get(date: tomorrow);
          expect(valueForTomorrow, 'foo');
          expect(storageFieldsServiceStub.diagnostics.reads, 1);
          expect(storageFieldsServiceStub.diagnostics.writes, 0);

          storageFieldsServiceStub.diagnostics.reset();

          final valueForPast = await lastIsValidPrimaryFieldWrapper.get(
            date: now.subtract(
              const Duration(days: 1),
            ),
          );
          expect(valueForPast, null);
          expect(storageFieldsServiceStub.diagnostics.reads, 0);
          expect(storageFieldsServiceStub.diagnostics.writes, 0);
        });

        test('Works correctly, if date is not passed', () async {
          await lastIsValidPrimaryFieldWrapper.set(
            value: 'foo',
          );
          expect(storageFieldsServiceStub.diagnostics.writes, 1);
          expect(storageFieldsServiceStub.diagnostics.reads, 0);

          storageFieldsServiceStub.diagnostics.reset();

          final value = await lastIsValidPrimaryFieldWrapper.get();
          expect(value, 'foo');
          expect(storageFieldsServiceStub.diagnostics.reads, 1);
          expect(storageFieldsServiceStub.diagnostics.writes, 0);
        });
      });
    });

    group(
      'Secondary',
      () {
        final baseDateFieldWrapper =
            _ConfigurablePrimaryFieldWrapper<DateTime?>(
          storageFieldsService: storageFieldsServiceStub,
          fieldCode: 'base_date_field_always_valid',
          validityParams: PrimaryFieldValidityParams.alwaysValid(),
        );
        // ignore: prefer-correct-identifier-length
        final calculatedFieldBasedOnAlwaysValidWrapper =
            _CalculatedFieldWrapper(
          storageFieldsServiceStub,
          alwaysValidPrimaryFieldWrapper,
          SecondaryFieldValidityParams.alwaysValid(),
          null,
        );
        // ignore: prefer-correct-identifier-length
        final calculatedFieldBasedOnValidForDayWrapper =
            _CalculatedFieldWrapper(
          storageFieldsServiceStub,
          validForDayPrimaryFieldWrapper,
          SecondaryFieldValidityParams.validForDay(),
          null,
        );
        // ignore: prefer-correct-identifier-length
        final calculatedFieldBasedOnLastIsValidWrapper =
            _CalculatedFieldWrapper(
          storageFieldsServiceStub,
          lastIsValidPrimaryFieldWrapper,
          SecondaryFieldValidityParams.lastIsValid(),
          null,
        );
        // ignore: prefer-correct-identifier-length
        final calculatedFieldBasedOnExternalDataForwardingWrapper =
            _CalculatedFieldWrapper(
          storageFieldsServiceStub,
          dateForwardingField,
          SecondaryFieldValidityParams.lastIsValid(),
          null,
        );

        group('Set', () {
          test('Does nothing', () async {
            await calculatedFieldBasedOnAlwaysValidWrapper.set(
              value: _ValueWrapper('foo'),
            );

            expect(storageFieldsServiceStub.diagnostics.reads, 0);
            expect(storageFieldsServiceStub.diagnostics.writes, 0);
          });
        });

        group('Get (base logic)', () {
          test(
            'Should return null if date is not passed and validity params is time series',
            () async {
              await validForDayPrimaryFieldWrapper.set(
                date: now,
                value: 'foo',
              );

              storageFieldsServiceStub.diagnostics.reset();

              final value =
                  await calculatedFieldBasedOnValidForDayWrapper.get();

              expect(
                value?.wrapped,
                null,
              );
              expect(
                storageFieldsServiceStub.diagnostics.reads,
                0,
                reason:
                    'No deps should be read, since date is not passed and validity params is time series',
              );
              expect(
                storageFieldsServiceStub.diagnostics.writes,
                0,
                reason: 'Secondary field should not be written afterwards',
              );
            },
          );

          test(
            'Should return value if date is not passed and validity params is "last is valid"',
            () async {
              await lastIsValidPrimaryFieldWrapper.set(
                date: now,
                value: 'foo',
              );

              storageFieldsServiceStub.diagnostics.reset();

              final value =
                  await calculatedFieldBasedOnLastIsValidWrapper.get();

              expect(
                value?.wrapped,
                'dep_1_for_date1: foo dep_1_for_date2: foo this_for_base_date: null',
              );
              expect(
                storageFieldsServiceStub.diagnostics.getReadsPerField(
                  wrapper: lastIsValidPrimaryFieldWrapper,
                  targetDate: now,
                ),
                1,
                reason: 'Deps should be read',
              );
              expect(
                storageFieldsServiceStub.diagnostics.reads,
                1,
              );
              expect(
                storageFieldsServiceStub.diagnostics.getWritesPerField(
                  wrapper: calculatedFieldBasedOnLastIsValidWrapper,
                  targetDate: null,
                ),
                1,
                reason: 'Secondary field should be written afterwards',
              );
              expect(
                storageFieldsServiceStub.diagnostics.writes,
                1,
              );
            },
          );

          test(
            'Should return value if date is not passed and validity params is "always valid"',
            () async {
              await alwaysValidPrimaryFieldWrapper.set(
                date: now,
                value: 'foo',
              );

              storageFieldsServiceStub.diagnostics.reset();

              final value =
                  await calculatedFieldBasedOnAlwaysValidWrapper.get();

              expect(
                value?.wrapped,
                'dep_1_for_date1: foo dep_1_for_date2: foo this_for_base_date: null',
              );
              expect(
                storageFieldsServiceStub.diagnostics.getReadsPerField(
                  wrapper: alwaysValidPrimaryFieldWrapper,
                  targetDate: null,
                ),
                1,
                reason: 'Deps should be read',
              );
              expect(
                storageFieldsServiceStub.diagnostics.reads,
                1,
              );
              expect(
                storageFieldsServiceStub.diagnostics.getWritesPerField(
                  wrapper: calculatedFieldBasedOnAlwaysValidWrapper,
                  targetDate: null,
                ),
                1,
                reason: 'Secondary field should be written afterwards',
              );
              expect(
                storageFieldsServiceStub.diagnostics.writes,
                1,
              );
            },
          );
        });

        group('Get (save and reuse saved value)', () {
          test('Works correctly if deps are not set at the start', () async {
            final value = await calculatedFieldBasedOnValidForDayWrapper.get(
              date: now,
            );
            expect(
              value?.wrapped,
              'dep_1_for_date1: null dep_1_for_date2: null this_for_base_date: null',
            );
            expect(
              storageFieldsServiceStub.diagnostics.reads,
              0,
              reason:
                  'Nothing should be read, since deps are not set and value has not yet cached',
            );
            expect(
              storageFieldsServiceStub.diagnostics.getWritesPerField(
                wrapper: calculatedFieldBasedOnValidForDayWrapper,
                targetDate: now,
              ),
              1,
            );
            expect(
              storageFieldsServiceStub.diagnostics.writes,
              1,
              reason: 'Only secondary field itself should be written',
            );

            await validForDayPrimaryFieldWrapper.set(
              date: now,
              value: 'foo',
            );

            storageFieldsServiceStub.diagnostics.reset();

            final valueAfterUpdate =
                await calculatedFieldBasedOnValidForDayWrapper.get(
              date: now,
            );
            expect(
              valueAfterUpdate?.wrapped,
              'dep_1_for_date1: foo dep_1_for_date2: null this_for_base_date: null',
              reason: '[after update] Should resolve expected value',
            );
            expect(
              storageFieldsServiceStub.diagnostics.getReadsPerField(
                wrapper: validForDayPrimaryFieldWrapper,
                targetDate: now,
              ),
              1,
              reason:
                  '[after update] All deps should be read again to recalculate value',
            );
            expect(storageFieldsServiceStub.diagnostics.reads, 1);
            expect(
              storageFieldsServiceStub.diagnostics.getWritesPerField(
                wrapper: calculatedFieldBasedOnValidForDayWrapper,
                targetDate: now,
              ),
              1,
              reason:
                  '[after update] Secondary field should be written afterwards',
            );
            expect(
              storageFieldsServiceStub.diagnostics.writes,
              1,
            );

            storageFieldsServiceStub.diagnostics.reset();
          });

          test(
            'Works correctly for "time series" properties with lot of dates',
            () async {
              final startOfSomeWeek = DateTime(2023, 6, 5);
              final validForWeekSecondaryFieldWrapper =
                  _ValidForWeekSecondaryFieldWrapper(
                storageFieldsServiceStub,
                validForDayPrimaryFieldWrapper,
              );
              for (var index = 0; index < 7; index++) {
                await validForDayPrimaryFieldWrapper.set(
                  date: startOfSomeWeek.add(Duration(days: index)),
                  value: (index + 1).toString(),
                );
              }

              storageFieldsServiceStub.diagnostics.reset();

              final value = await validForWeekSecondaryFieldWrapper.get(
                date: startOfSomeWeek,
              );

              expect(
                value,
                '1: 1, 2: 2, 3: 3, 4: 4, 5: 5, 6: 6, 7: 7',
              );
              expect(
                storageFieldsServiceStub.diagnostics.getReadsPerField(
                  wrapper: validForDayPrimaryFieldWrapper,
                  targetDate: startOfSomeWeek,
                ),
                1,
                reason: 'Dependency for day 1 should be read',
              );
              expect(
                storageFieldsServiceStub.diagnostics.getReadsPerField(
                  wrapper: validForDayPrimaryFieldWrapper,
                  targetDate: startOfSomeWeek.add(const Duration(days: 1)),
                ),
                1,
                reason: 'Dependency for day 2 should be read',
              );
              expect(
                storageFieldsServiceStub.diagnostics.getReadsPerField(
                  wrapper: validForDayPrimaryFieldWrapper,
                  targetDate: startOfSomeWeek.add(const Duration(days: 2)),
                ),
                1,
                reason: 'Dependency for day 3 should be read',
              );
              expect(
                storageFieldsServiceStub.diagnostics.getReadsPerField(
                  wrapper: validForDayPrimaryFieldWrapper,
                  targetDate: startOfSomeWeek.add(const Duration(days: 3)),
                ),
                1,
                reason: 'Dependency for day 4 should be read',
              );
              expect(
                storageFieldsServiceStub.diagnostics.getReadsPerField(
                  wrapper: validForDayPrimaryFieldWrapper,
                  targetDate: startOfSomeWeek.add(const Duration(days: 4)),
                ),
                1,
                reason: 'Dependency for day 5 should be read',
              );
              expect(
                storageFieldsServiceStub.diagnostics.getReadsPerField(
                  wrapper: validForDayPrimaryFieldWrapper,
                  targetDate: startOfSomeWeek.add(const Duration(days: 5)),
                ),
                1,
                reason: 'Dependency for day 6 should be read',
              );
              expect(
                storageFieldsServiceStub.diagnostics.getReadsPerField(
                  wrapper: validForDayPrimaryFieldWrapper,
                  targetDate: startOfSomeWeek.add(const Duration(days: 6)),
                ),
                1,
                reason: 'Dependency for day 7 should be read',
              );
              expect(
                storageFieldsServiceStub.diagnostics.reads,
                7,
              );
              expect(
                storageFieldsServiceStub.diagnostics.getWritesPerField(
                  wrapper: validForWeekSecondaryFieldWrapper,
                  targetDate: startOfSomeWeek,
                ),
                1,
                reason: 'Secondary field should be written afterwards',
              );
              expect(
                storageFieldsServiceStub.diagnostics.writes,
                1,
              );

              await validForDayPrimaryFieldWrapper.set(
                date: startOfSomeWeek,
                value: '1_updated',
              );
              await validForDayPrimaryFieldWrapper.set(
                date: startOfSomeWeek.add(const Duration(days: 1)),
                value: '2_updated',
              );

              storageFieldsServiceStub.diagnostics.reset();

              final updatedValue = await validForWeekSecondaryFieldWrapper.get(
                date: startOfSomeWeek,
              );

              expect(
                updatedValue,
                '1: 1_updated, 2: 2_updated, 3: 3, 4: 4, 5: 5, 6: 6, 7: 7',
              );
              expect(
                storageFieldsServiceStub.diagnostics.getReadsPerField(
                  wrapper: validForDayPrimaryFieldWrapper,
                  targetDate: startOfSomeWeek,
                ),
                1,
                reason: '[after update] Dependency for day 1 should be read',
              );
              expect(
                storageFieldsServiceStub.diagnostics.getReadsPerField(
                  wrapper: validForDayPrimaryFieldWrapper,
                  targetDate: startOfSomeWeek.add(const Duration(days: 1)),
                ),
                1,
                reason: '[after update] Dependency for day 2 should be read',
              );
              expect(
                storageFieldsServiceStub.diagnostics.getReadsPerField(
                  wrapper: validForDayPrimaryFieldWrapper,
                  targetDate: startOfSomeWeek.add(const Duration(days: 2)),
                ),
                1,
                reason: '[after update] Dependency for day 3 should be read',
              );
              expect(
                storageFieldsServiceStub.diagnostics.getReadsPerField(
                  wrapper: validForDayPrimaryFieldWrapper,
                  targetDate: startOfSomeWeek.add(const Duration(days: 3)),
                ),
                1,
                reason: '[after update] Dependency for day 4 should be read',
              );
              expect(
                storageFieldsServiceStub.diagnostics.getReadsPerField(
                  wrapper: validForDayPrimaryFieldWrapper,
                  targetDate: startOfSomeWeek.add(const Duration(days: 4)),
                ),
                1,
                reason: '[after update] Dependency for day 5 should be read',
              );
              expect(
                storageFieldsServiceStub.diagnostics.getReadsPerField(
                  wrapper: validForDayPrimaryFieldWrapper,
                  targetDate: startOfSomeWeek.add(const Duration(days: 5)),
                ),
                1,
                reason: '[after update] Dependency for day 6 should be read',
              );
              expect(
                storageFieldsServiceStub.diagnostics.getReadsPerField(
                  wrapper: validForDayPrimaryFieldWrapper,
                  targetDate: startOfSomeWeek.add(const Duration(days: 6)),
                ),
                1,
                reason: '[after update] Dependency for day 7 should be read',
              );
              expect(
                storageFieldsServiceStub.diagnostics.reads,
                7,
              );
              expect(
                storageFieldsServiceStub.diagnostics.getWritesPerField(
                  wrapper: validForWeekSecondaryFieldWrapper,
                  targetDate: startOfSomeWeek,
                ),
                1,
                reason:
                    '[after update] Secondary field should be written afterwards',
              );
              expect(
                storageFieldsServiceStub.diagnostics.writes,
                1,
              );
            },
          );

          test('Works correctly with time series deps', () async {
            await validForDayPrimaryFieldWrapper.set(
              date: now,
              value: 'foo',
            );
            await validForDayPrimaryFieldWrapper.set(
              date: tomorrow,
              value: 'bar',
            );

            storageFieldsServiceStub.diagnostics.reset();

            final value = await calculatedFieldBasedOnValidForDayWrapper.get(
              date: now,
            );

            expect(
              value?.wrapped,
              'dep_1_for_date1: foo dep_1_for_date2: bar this_for_base_date: null',
            );
            expect(
              storageFieldsServiceStub.diagnostics.getReadsPerField(
                wrapper: validForDayPrimaryFieldWrapper,
                targetDate: now,
              ),
              1,
              reason:
                  'Dep for today should be read because value has not been yet cached',
            );
            expect(
              storageFieldsServiceStub.diagnostics.getReadsPerField(
                wrapper: validForDayPrimaryFieldWrapper,
                targetDate: tomorrow,
              ),
              1,
              reason:
                  'Dep for tomorrow should be read because value has not been yet cached',
            );
            expect(
              storageFieldsServiceStub.diagnostics.reads,
              2,
            );
            expect(
              storageFieldsServiceStub.diagnostics.getWritesPerField(
                wrapper: calculatedFieldBasedOnValidForDayWrapper,
                targetDate: now,
              ),
              1,
              reason: 'Secondary field should be written afterwards',
            );
            expect(
              storageFieldsServiceStub.diagnostics.writes,
              1,
            );

            await validForDayPrimaryFieldWrapper.set(
              date: now,
              value: 'buz',
            );

            storageFieldsServiceStub.diagnostics.reset();

            final valueAfterUpdate =
                await calculatedFieldBasedOnValidForDayWrapper.get(
              date: now,
            );
            expect(
              valueAfterUpdate?.wrapped,
              'dep_1_for_date1: buz dep_1_for_date2: bar this_for_base_date: null',
            );
            expect(
              storageFieldsServiceStub.diagnostics.getReadsPerField(
                wrapper: validForDayPrimaryFieldWrapper,
                targetDate: now,
              ),
              1,
              reason:
                  '[after update] Dep for today should be read to recalculate value',
            );
            expect(
              storageFieldsServiceStub.diagnostics.getReadsPerField(
                wrapper: validForDayPrimaryFieldWrapper,
                targetDate: tomorrow,
              ),
              1,
              reason:
                  '[after update] Dep for tomorrow should be read to recalculate value',
            );
            expect(
              storageFieldsServiceStub.diagnostics.reads,
              2,
            );
            expect(
              storageFieldsServiceStub.diagnostics.getWritesPerField(
                wrapper: calculatedFieldBasedOnValidForDayWrapper,
                targetDate: now,
              ),
              1,
              reason:
                  '[after update] Secondary field should be written afterwards',
            );
            expect(
              storageFieldsServiceStub.diagnostics.writes,
              1,
            );
          });

          test('Works correctly with "last is valid" deps', () async {
            await lastIsValidPrimaryFieldWrapper.set(
              date: now,
              value: 'foo',
            );
            await lastIsValidPrimaryFieldWrapper.set(
              date: now.subtract(const Duration(days: 10)),
              value: 'bar',
            );

            storageFieldsServiceStub.diagnostics.reset();

            final value = await calculatedFieldBasedOnLastIsValidWrapper.get(
              date: now,
            );

            expect(
              value?.wrapped,
              'dep_1_for_date1: foo dep_1_for_date2: foo this_for_base_date: null',
            );
            expect(
              storageFieldsServiceStub.diagnostics.getReadsPerField(
                wrapper: lastIsValidPrimaryFieldWrapper,
                targetDate: null,
              ),
              2,
              reason:
                  'All deps should be read if value has not been yet cached',
            );
            expect(
              storageFieldsServiceStub.diagnostics.reads,
              2,
            );
            expect(
              storageFieldsServiceStub.diagnostics.getWritesPerField(
                wrapper: calculatedFieldBasedOnLastIsValidWrapper,
                targetDate: now,
              ),
              1,
              reason: 'Secondary field should be written afterwards',
            );
            expect(
              storageFieldsServiceStub.diagnostics.writes,
              1,
            );

            await lastIsValidPrimaryFieldWrapper.set(
              date: now,
              value: 'buz',
            );

            storageFieldsServiceStub.diagnostics.reset();

            final valueAfterUpdate =
                await calculatedFieldBasedOnLastIsValidWrapper.get(
              date: now,
            );
            expect(
              valueAfterUpdate?.wrapped,
              'dep_1_for_date1: buz dep_1_for_date2: buz this_for_base_date: null',
            );
            expect(
              storageFieldsServiceStub.diagnostics.getReadsPerField(
                wrapper: lastIsValidPrimaryFieldWrapper,
                targetDate: null,
              ),
              2,
              reason:
                  '[after update] Deps should be read again to recalculate value',
            );
            expect(
              storageFieldsServiceStub.diagnostics.reads,
              2,
            );
            expect(
              storageFieldsServiceStub.diagnostics.getWritesPerField(
                wrapper: calculatedFieldBasedOnLastIsValidWrapper,
                targetDate: now,
              ),
              1,
              reason:
                  '[after update] Secondary field should be written afterwards',
            );
            expect(
              storageFieldsServiceStub.diagnostics.writes,
              1,
            );
          });

          test('Works correctly with "always valid" deps', () async {
            await alwaysValidPrimaryFieldWrapper.set(
              date: now,
              value: 'foo',
            );

            storageFieldsServiceStub.diagnostics.reset();

            final value = await calculatedFieldBasedOnAlwaysValidWrapper.get(
              date: now,
            );

            expect(
              value?.wrapped,
              'dep_1_for_date1: foo dep_1_for_date2: foo this_for_base_date: null',
            );
            expect(
              storageFieldsServiceStub.diagnostics.getReadsPerField(
                wrapper: alwaysValidPrimaryFieldWrapper,
                targetDate: null,
              ),
              2,
              reason:
                  'All deps should be read if value has not been yet cached',
            );
            expect(
              storageFieldsServiceStub.diagnostics.reads,
              2,
            );
            expect(
              storageFieldsServiceStub.diagnostics.getWritesPerField(
                wrapper: calculatedFieldBasedOnAlwaysValidWrapper,
                targetDate: now,
              ),
              1,
              reason: 'Secondary field should be written afterwards',
            );
            expect(
              storageFieldsServiceStub.diagnostics.writes,
              1,
            );

            await alwaysValidPrimaryFieldWrapper.set(
              date: now,
              value: 'buz',
            );

            storageFieldsServiceStub.diagnostics.reset();

            final valueAfterUpdate =
                await calculatedFieldBasedOnAlwaysValidWrapper.get(
              date: now,
            );
            expect(
              valueAfterUpdate?.wrapped,
              'dep_1_for_date1: buz dep_1_for_date2: buz this_for_base_date: null',
            );
            expect(
              storageFieldsServiceStub.diagnostics.getReadsPerField(
                wrapper: alwaysValidPrimaryFieldWrapper,
                targetDate: null,
              ),
              2,
              reason:
                  '[after update] Deps should be read again to recalculate value',
            );
            expect(
              storageFieldsServiceStub.diagnostics.reads,
              2,
            );
            expect(
              storageFieldsServiceStub.diagnostics.getWritesPerField(
                wrapper: calculatedFieldBasedOnAlwaysValidWrapper,
                targetDate: now,
              ),
              1,
              reason:
                  '[after update] Secondary field should be written afterwards',
            );
            expect(
              storageFieldsServiceStub.diagnostics.writes,
              1,
            );
          });

          test(
            'Works correctly with "external data forwarding" deps',
            () async {
              final value =
                  await calculatedFieldBasedOnExternalDataForwardingWrapper.get(
                      date: now);

              expect(
                value?.wrapped,
                'dep_1_for_date1: ${now.toIso8601String()} dep_1_for_date2: ${tomorrow.toIso8601String()} this_for_base_date: null',
              );
              expect(
                storageFieldsServiceStub.diagnostics.reads,
                0,
                reason: 'Nothing should be read, since all deps are external',
              );
              expect(
                storageFieldsServiceStub.diagnostics.getWritesPerField(
                  wrapper: calculatedFieldBasedOnExternalDataForwardingWrapper,
                  targetDate: now,
                ),
                1,
                reason: 'Secondary field should be written afterwards',
              );
              expect(
                storageFieldsServiceStub.diagnostics.writes,
                1,
              );

              storageFieldsServiceStub.diagnostics.reset();

              final nextValue =
                  await calculatedFieldBasedOnExternalDataForwardingWrapper.get(
                      date: now);
              expect(
                nextValue?.wrapped,
                'dep_1_for_date1: ${now.toIso8601String()} dep_1_for_date2: ${tomorrow.toIso8601String()} this_for_base_date: null',
              );
              expect(
                identityHashCode(nextValue),
                isNot(identityHashCode(value)),
                reason:
                    '[get again without updates] Cached value should not be reused since deps are external',
              );
              expect(
                storageFieldsServiceStub.diagnostics.reads,
                0,
              );
              expect(
                storageFieldsServiceStub.diagnostics.getWritesPerField(
                  wrapper: calculatedFieldBasedOnExternalDataForwardingWrapper,
                  targetDate: now,
                ),
                1,
                reason:
                    '[get again without updates] Value should be saved again, since deps are forwarded',
              );
              expect(
                storageFieldsServiceStub.diagnostics.writes,
                1,
              );
            },
          );

          test('Works correctly with base date and self referencing', () async {
            final secondaryField = _CalculatedFieldWrapper(
              storageFieldsServiceStub,
              validForDayPrimaryFieldWrapper,
              SecondaryFieldValidityParams.validForDay(),
              baseDateFieldWrapper,
            );
            await validForDayPrimaryFieldWrapper.set(
              date: now,
              value: 'foo',
            );
            await validForDayPrimaryFieldWrapper.set(
              date: tomorrow,
              value: 'bar',
            );

            storageFieldsServiceStub.diagnostics.reset();

            final value = await secondaryField.get(date: now);

            expect(
              value?.wrapped,
              'dep_1_for_date1: foo dep_1_for_date2: bar this_for_base_date: null',
            );
            expect(
              storageFieldsServiceStub.diagnostics.getReadsPerField(
                wrapper: validForDayPrimaryFieldWrapper,
                targetDate: now,
              ),
              1,
              reason:
                  'Dep for today should be read if value has not been yet cached',
            );
            expect(
              storageFieldsServiceStub.diagnostics.getReadsPerField(
                wrapper: validForDayPrimaryFieldWrapper,
                targetDate: tomorrow,
              ),
              1,
              reason:
                  'Dep for tomorrow should be read if value has not been yet cached',
            );
            expect(
              storageFieldsServiceStub.diagnostics.reads,
              2,
            );
            expect(
              storageFieldsServiceStub.diagnostics.getWritesPerField(
                wrapper: secondaryField,
                targetDate: now,
              ),
              1,
              reason: 'Secondary field should be written afterwards',
            );
            expect(
              storageFieldsServiceStub.diagnostics.writes,
              1,
            );

            baseDateFieldWrapper.set(value: now);
            storageFieldsServiceStub.diagnostics.reset();

            final valueAfterBaseDate = await secondaryField.get(date: now);
            expect(
              valueAfterBaseDate?.wrapped,
              'dep_1_for_date1: foo dep_1_for_date2: bar this_for_base_date: null',
            );
            expect(
              storageFieldsServiceStub.diagnostics.getReadsPerField(
                wrapper: validForDayPrimaryFieldWrapper,
                targetDate: now,
              ),
              1,
              reason: '[base date update] Dep for today should be read',
            );
            expect(
              storageFieldsServiceStub.diagnostics.getReadsPerField(
                wrapper: validForDayPrimaryFieldWrapper,
                targetDate: tomorrow,
              ),
              1,
              reason: '[base date update] Dep for tomorrow should be read',
            );
            expect(
              storageFieldsServiceStub.diagnostics.getReadsPerField(
                wrapper: baseDateFieldWrapper,
                targetDate: null,
              ),
              1,
              reason: '[base date update] Base date should be read',
            );
            expect(
              storageFieldsServiceStub.diagnostics.reads,
              3,
            );
            expect(
              storageFieldsServiceStub.diagnostics.getWritesPerField(
                wrapper: secondaryField,
                targetDate: now,
              ),
              1,
              reason: '[base date update] Saved value should be written again',
            );
            expect(
              storageFieldsServiceStub.diagnostics.writes,
              1,
            );

            storageFieldsServiceStub.diagnostics.reset();

            final valueForTomorrow = await secondaryField.get(
              date: tomorrow,
            );
            expect(
              valueForTomorrow?.wrapped,
              'dep_1_for_date1: bar dep_1_for_date2: null this_for_base_date: "dep_1_for_date1: foo dep_1_for_date2: bar this_for_base_date: null"',
            );
            expect(
              storageFieldsServiceStub.diagnostics.getReadsPerField(
                wrapper: validForDayPrimaryFieldWrapper,
                targetDate: now,
              ),
              1,
              reason: '[for tomorrow] Dep should be read for today',
            );
            expect(
              storageFieldsServiceStub.diagnostics.getReadsPerField(
                wrapper: validForDayPrimaryFieldWrapper,
                targetDate: tomorrow,
              ),
              2,
              reason: '[for tomorrow] Deps should be read for tomorrow',
            );

            expect(
              storageFieldsServiceStub.diagnostics.getReadsPerField(
                wrapper: baseDateFieldWrapper,
                targetDate: null,
              ),
              2,
              reason: '[for tomorrow] Base date should be read twice:\n'
                  '1. When resolving deps for target date\n'
                  '2. When resolving deps for base date ',
            );
            expect(
              storageFieldsServiceStub.diagnostics.reads,
              5,
            );
            expect(
              storageFieldsServiceStub.diagnostics.getWritesPerField(
                wrapper: secondaryField,
                targetDate: now,
              ),
              1,
              reason:
                  '[for tomorrow] Secondary field should be written afterwards for today',
            );
            expect(
              storageFieldsServiceStub.diagnostics.getWritesPerField(
                wrapper: secondaryField,
                targetDate: tomorrow,
              ),
              1,
              reason:
                  '[for tomorrow] Secondary field should be written afterwards',
            );
            expect(
              storageFieldsServiceStub.diagnostics.writes,
              2,
            );
          });

          test(
            'Works correctly with base date and data forwarding deps',
            () async {
              final secondaryField = _CalculatedFieldWrapper(
                storageFieldsServiceStub,
                dateForwardingField,
                SecondaryFieldValidityParams.validForDay(),
                baseDateFieldWrapper,
                useBaseDateAsParamForDependencyField: true,
              );

              final baseDate = DateTime(2020, 12, 12);
              baseDateFieldWrapper.set(value: baseDate);
              storageFieldsServiceStub.diagnostics.reset();

              final value = await secondaryField.get(date: now);

              expect(
                value?.wrapped,
                'dep_1_for_date1: 2020-12-12T00:00:00.000 dep_1_for_date2: 2020-12-13T00:00:00.000 this_for_base_date: "dep_1_for_date1: 2020-12-12T00:00:00.000 dep_1_for_date2: 2020-12-13T00:00:00.000 this_for_base_date: null"',
              );
              expect(
                storageFieldsServiceStub.diagnostics.getReadsPerField(
                  wrapper: baseDateFieldWrapper,
                  targetDate: null,
                ),
                2,
                reason: 'Base date should be read twice:\n'
                    '1. When resolving deps\n'
                    '2. When resolving self value for base date',
              );
              expect(
                storageFieldsServiceStub.diagnostics.getReadsPerField(
                  wrapper: dateForwardingField,
                  targetDate: null,
                ),
                0,
                reason:
                    'Deps should not be read since forwarding field is used',
              );
              expect(
                storageFieldsServiceStub.diagnostics.reads,
                2,
              );
              expect(
                storageFieldsServiceStub.diagnostics.getWritesPerField(
                  wrapper: secondaryField,
                  targetDate: now,
                ),
                1,
                reason:
                    'Secondary field should be written when resolving for date',
              );
              expect(
                storageFieldsServiceStub.diagnostics.getWritesPerField(
                  wrapper: secondaryField,
                  targetDate: baseDate,
                ),
                1,
                reason:
                    'Secondary field should be written when resolving for base date',
              );
              expect(
                storageFieldsServiceStub.diagnostics.writes,
                2,
              );
            },
          );

          test(
            'Recalculates when one secondary field depends on another with "last is valid" dep '
            'and "last is valid" dep of another is updated',
            () async {
              final lastIsValidPrimaryIntFieldWrapper =
                  _ConfigurablePrimaryFieldWrapper<int>(
                storageFieldsService: storageFieldsServiceStub,
                fieldCode: 'last_valid_int',
                validityParams: PrimaryFieldValidityParams.lastIsValid(),
              );
              final anotherSecondaryField = _IncrementingStorageFieldWrapper(
                storageFieldsService: storageFieldsServiceStub,
                validityParams: SecondaryFieldValidityParams.lastIsValid(),
                dependencyFieldWrapper: lastIsValidPrimaryIntFieldWrapper,
                codeSuffix: 'another',
              );
              final secondaryField = _IncrementingStorageFieldWrapper(
                storageFieldsService: storageFieldsServiceStub,
                validityParams: SecondaryFieldValidityParams.lastIsValid(),
                dependencyFieldWrapper: anotherSecondaryField,
                codeSuffix: '',
              );

              final valueBeforeAnyUpdate = await secondaryField.get(
                date: now,
              );

              expect(valueBeforeAnyUpdate, null);

              lastIsValidPrimaryIntFieldWrapper.set(value: 1, date: now);
              final valueAfterFirstUpdate = await secondaryField.get(
                date: now,
              );
              expect(valueAfterFirstUpdate, 3);

              lastIsValidPrimaryIntFieldWrapper.set(value: 2, date: now);
              final valueAfterSecondUpdate = await secondaryField.get(
                date: now,
              );
              expect(valueAfterSecondUpdate, 4);
            },
          );
        });
      },
    );
  });
}

class _ValidForWeekSecondaryFieldWrapper extends SecondaryStorageFieldWrapper<
    String, DependencyResolveResult1<String>> {
  @override
  final StorageFieldsService storageFieldsService;
  final StorageFieldWrapper<String> validForDayPrimaryFieldWrapper;

  _ValidForWeekSecondaryFieldWrapper(
    this.storageFieldsService,
    this.validForDayPrimaryFieldWrapper,
  );

  @override
  String get fieldCode => 'valid_for_week_secondary_field';

  @override
  SecondaryFieldValidityParams get validityParams =>
      SecondaryFieldValidityParams.validForWeek();

  @override
  JsonConverter<String?, Object?> get valueConverter =>
      const _AsIsValueConverter();

  @override
  DependencyResolver<DependencyResolveResult1<String>> get dependencyResolver =>
      DependencyResolver1(
        dep1: DependencyItem(
          fieldWrapper: validForDayPrimaryFieldWrapper,
          onGetFieldDates: (params) =>
              validityParams.dateGroup?.createDayGranularityDateGroupKeys(
                targetDate: params.date,
              ) ??
              [],
        ),
      );

  @override
  String calculate(DependencyResolveResult1<String> resolveResult) {
    return resolveResult.item1
        .mapIndexed(
          (index, value) => '${index + 1}: $value',
        )
        .join(', ');
  }
}

class _CalculatedFieldWrapper extends SecondaryStorageFieldWrapper<
    _ValueWrapper, DependencyResolveResult2<String, _ValueWrapper>> {
  @override
  final StorageFieldsService storageFieldsService;
  final StorageFieldWrapper<String> dependencyFieldWrapper;
  @override
  final SecondaryFieldValidityParams validityParams;

  final StorageFieldWrapper<DateTime?>? baseDateFieldWrapper;
  final bool useBaseDateAsParamForDependencyField;

  _CalculatedFieldWrapper(
    this.storageFieldsService,
    this.dependencyFieldWrapper,
    this.validityParams,
    this.baseDateFieldWrapper, {
    this.useBaseDateAsParamForDependencyField = false,
  });

  @override
  String get fieldCode => 'calculated_field';

  @override
  JsonConverter<_ValueWrapper?, Object?> get valueConverter =>
      const _AsIsValueConverter();

  @override
  StorageFieldWrapper<DateTime?>? get baseDateDependency =>
      baseDateFieldWrapper;

  @override
  DependencyResolver<DependencyResolveResult2<String, _ValueWrapper>>
      get dependencyResolver => DependencyResolver2(
            dep1: DependencyItem(
              fieldWrapper: dependencyFieldWrapper,
              onGetFieldDates: (params) {
                final date = useBaseDateAsParamForDependencyField
                    ? params.baseDate
                    : params.date;

                return [
                  // ignore: avoid-non-null-assertion
                  date!,
                  date.add(
                    const Duration(days: 1),
                  ),
                ];
              },
            ),
            dep2: DependencyItem(
              fieldWrapper: this,
              onGetFieldDates: (params) {
                final baseDate = params.baseDate;
                // If baseDate is null, then we don't need to resolve this field
                // If baseDate is the same as current date we do not resolve to avoid infinite loop
                if (baseDate == null ||
                    params.date.isAtSameMomentAs(baseDate)) {
                  return null;
                }

                return [baseDate];
              },
            ),
          );

  @override
  _ValueWrapper calculate(
    DependencyResolveResult2<String, _ValueWrapper> resolveResult,
  ) {
    final dep1ForDate1 = resolveResult.item1.firstOrNull;
    final dep1ForDate2 = resolveResult.item1.lastOrNull;
    final thisForBaseDate = resolveResult.item2.firstOrNull;

    return _ValueWrapper(
      'dep_1_for_date1: $dep1ForDate1 dep_1_for_date2: $dep1ForDate2 this_for_base_date: ${thisForBaseDate == null ? 'null' : '"${thisForBaseDate.wrapped}"'}',
    );
  }
}

class _IncrementingStorageFieldWrapper
    extends SecondaryStorageFieldWrapper<int?, DependencyResolveResult1<int?>> {
  @override
  final StorageFieldsService storageFieldsService;
  final StorageFieldWrapper<int?> dependencyFieldWrapper;
  @override
  final SecondaryFieldValidityParams validityParams;
  final String codeSuffix;

  _IncrementingStorageFieldWrapper({
    required this.storageFieldsService,
    required this.dependencyFieldWrapper,
    required this.validityParams,
    required this.codeSuffix,
  });

  @override
  String get fieldCode => 'incrementing_secondary_field$codeSuffix';

  @override
  JsonConverter<int?, Object?> get valueConverter =>
      const _AsIsValueConverter();

  @override
  DependencyResolver<DependencyResolveResult1<int?>> get dependencyResolver =>
      DependencyResolver1(
        dep1: DependencyItem(
          fieldWrapper: dependencyFieldWrapper,
          onGetFieldDates: (params) => [params.date],
        ),
      );

  @override
  int? calculate(
    DependencyResolveResult1<int?> resolveResult,
  ) {
    final depValue = resolveResult.item1.firstOrNull;

    return depValue == null ? null : depValue + 1;
  }
}

class _ConfigurablePrimaryFieldWrapper<T>
    extends PrimaryStorageFieldWrapper<T> {
  @override
  final StorageFieldsService storageFieldsService;
  @override
  final String fieldCode;
  @override
  final PrimaryFieldValidityParams validityParams;

  _ConfigurablePrimaryFieldWrapper({
    required this.storageFieldsService,
    required this.fieldCode,
    required this.validityParams,
  });

  @override
  JsonConverter<T?, Object?> get valueConverter => _AsIsValueConverter<T>();
}

/// Simulates a field that uses external source to get the value
class _DateForwardingField extends ForwardingStorageFieldWrapper<String> {
  @override
  final StorageFieldsService storageFieldsService;

  _DateForwardingField(this.storageFieldsService);

  @override
  String get fieldCode => 'date_forwarding_field';

  @override
  ForwardingFieldValidityParams get validityParams =>
      ForwardingFieldValidityParams.validForDay();

  @override
  JsonConverter<String?, Object?> get valueConverter =>
      const _AsIsValueConverter();

  @override
  Future<String?> resolve({
    DateTime? date,
  }) async {
    return date?.toIso8601String();
  }
}

class _AsIsValueConverter<T> implements JsonConverter<T?, Object?> {
  const _AsIsValueConverter();

  @override
  T? fromJson(Object? json) {
    return json as T?;
  }

  @override
  // ignore: no-object-declaration
  Object? toJson(T? object) {
    return object;
  }
}

// Helper class to wrap String SF values to avoid comparison issues
// (Same strings in dart are the same objects in terms of identity)
class _ValueWrapper {
  final String wrapped;

  _ValueWrapper(this.wrapped);
}
