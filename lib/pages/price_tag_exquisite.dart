import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/price_tag_exq_controller.dart';
import '../widgets/text_field.dart';

class PriceTagLabelExquisiteView extends StatelessWidget {
  const PriceTagLabelExquisiteView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(PriceTagExqController());
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Price Tag Exquisite"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 800;
              return isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildEditAndListSection(constraints),
                        const SizedBox(width: 16),
                        _buildPreviewSection(),
                      ],
                    )
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildEditAndListSection(constraints),
                          const SizedBox(height: 16),
                          _buildPreviewSection(),
                        ],
                      ),
                    );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEditAndListSection(BoxConstraints constraints) {
    var con = Get.find<PriceTagExqController>();
    return Expanded(
      flex: 3,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Edit Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormFieldWidget(
                    text: "Name",
                    controller: con.nameController,
                    onFieldSubmitted: (value) {},
                  ),
                  TextFormFieldWidget(
                    text: "Old Price",
                    controller: con.oldPriceController,
                    onFieldSubmitted: (value) {},
                  ),
                  TextFormFieldWidget(
                    text: "New Price",
                    controller: con.newPriceController,
                    onFieldSubmitted: (value) {},
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          con.clearInputs();
                        },
                        child: const Text("Clear"),
                      ),
                      Obx(() => ElevatedButton(
                            onPressed: () {
                              con.saveOrUpdateItem();
                            },
                            child:
                                Text(con.isEditMode.value ? "Update" : "Save"),
                          )),
                      ElevatedButton(
                        onPressed: con.downloadPdf,
                        child: const Text("Export"),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),
            // List View Section
            Container(
              width: double.infinity,
              height: 400,
              decoration: BoxDecoration(
                color: Colors.lightBlueAccent.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  // Header Row
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: const BoxDecoration(
                      color: Colors.blueGrey,
                    ),
                    child: const Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Sl No",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            "Name",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "Old Price",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "New Price",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(left: 28),
                            child: Text(
                              "Edit",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Data List
                  Expanded(
                    child: Obx(() => ListView.builder(
                          itemCount: con.data.length,
                          itemBuilder: (context, index) {
                            var item = con.data[index];
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "${index + 1}",
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      item.name,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      item.oldPrice.toString(),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      item.newPrice.toString(),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit,
                                            color: Colors.blue),
                                        onPressed: () {
                                          con.editItem(index);
                                        },
                                        visualDensity: const VisualDensity(
                                            horizontal: -4, vertical: -4),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.blue),
                                        onPressed: () {
                                          con.removeDataByIndex(index);
                                        },
                                        visualDensity: const VisualDensity(
                                            horizontal: -4, vertical: -4),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        )),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // preferences
            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Preferences",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Obx(
                        () => Checkbox.adaptive(
                          value: con.isStrikeThrogh.value,
                          onChanged: con.toggleStrikeThgrough,
                        ),
                      ),
                      const Text("Strike through")
                    ],
                  ),
                  Row(
                    children: [
                      const Text("Text: "),
                      SizedBox(
                        height: 50,
                        width: 250,
                        child: TextFormField(
                          onChanged: con.updateText,
                          initialValue: con.smallText.value,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Colors.black),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Colors.blue),
                            ),
                            fillColor: Colors.white,
                            filled: true,
                          ),
                        ),
                      )
                    ],
                  ),
                  Obx(() => ListTile(
                        title: const Text('Click here to change this color'),
                        subtitle: Text(
                            '${ColorTools.materialNameAndCode(con.pickedColor.value)} '
                            'aka ${ColorTools.nameThatColor(con.pickedColor.value)}'),
                        trailing: ColorIndicator(
                          width: 44,
                          height: 44,
                          borderRadius: 0,
                          color: con.pickedColor.value,
                        ),
                        onTap: () async {
                          final Color colorBeforeDialog = con.pickedColor.value;
                          if (!(await colorPickerDialog(Get.context!))) {
                            con.selectColor(colorBeforeDialog);
                          }
                        },
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> colorPickerDialog(BuildContext context) async {
    var con = Get.find<PriceTagExqController>();
    const Color guidePrimary = Color(0xFF6200EE);
    const Color guidePrimaryVariant = Color(0xFF3700B3);
    const Color guideSecondary = Color(0xFF03DAC6);
    const Color guideSecondaryVariant = Color(0xFF018786);
    const Color guideError = Color(0xFFB00020);
    const Color guideErrorDark = Color(0xFFCF6679);
    const Color blueBlues = Color(0xFF174378);
    // Make a custom ColorSwatch to name map from the above custom colors.
    final Map<ColorSwatch<Object>, String> colorsNameMap =
        <ColorSwatch<Object>, String>{
      ColorTools.createPrimarySwatch(guidePrimary): 'Guide Purple',
      ColorTools.createPrimarySwatch(guidePrimaryVariant):
          'Guide Purple Variant',
      ColorTools.createAccentSwatch(guideSecondary): 'Guide Teal',
      ColorTools.createAccentSwatch(guideSecondaryVariant):
          'Guide Teal Variant',
      ColorTools.createPrimarySwatch(guideError): 'Guide Error',
      ColorTools.createPrimarySwatch(guideErrorDark): 'Guide Error Dark',
      ColorTools.createPrimarySwatch(blueBlues): 'Blue blues',
    };
    return ColorPicker(
      // Use the dialogPickerColor as start and active color.
      color: con.pickedColor.value,
      // Update the dialogPickerColor using the callback.
      onColorChanged: (Color color) {
        con.selectColor(color);
      },
      width: 40,
      height: 40,
      borderRadius: 4,
      spacing: 5,
      runSpacing: 5,
      wheelDiameter: 155,
      heading: Text(
        'Select color',
        style: Theme.of(context).textTheme.titleSmall,
      ),
      subheading: Text(
        'Select color shade',
        style: Theme.of(context).textTheme.titleSmall,
      ),
      wheelSubheading: Text(
        'Selected color and its shades',
        style: Theme.of(context).textTheme.titleSmall,
      ),
      showMaterialName: true,
      showColorName: true,
      showColorCode: true,
      copyPasteBehavior: const ColorPickerCopyPasteBehavior(
        longPressMenu: true,
      ),
      materialNameTextStyle: Theme.of(context).textTheme.bodySmall,
      colorNameTextStyle: Theme.of(context).textTheme.bodySmall,
      colorCodeTextStyle: Theme.of(context).textTheme.bodySmall,
      pickersEnabled: const <ColorPickerType, bool>{
        ColorPickerType.both: false,
        ColorPickerType.primary: true,
        ColorPickerType.accent: true,
        ColorPickerType.bw: false,
        ColorPickerType.custom: true,
        ColorPickerType.wheel: true,
      },
      customColorSwatchesAndNames: colorsNameMap,
    ).showPickerDialog(
      context,
      // New in version 3.0.0 custom transitions support.
      transitionBuilder: (BuildContext context, Animation<double> a1,
          Animation<double> a2, Widget widget) {
        final double curvedValue =
            Curves.easeInOutBack.transform(a1.value) - 1.0;
        return Transform(
          transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
          child: Opacity(
            opacity: a1.value,
            child: widget,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
      constraints:
          const BoxConstraints(minHeight: 460, minWidth: 300, maxWidth: 320),
    );
  }

  Widget _buildPreviewSection() {
    var con = Get.find<PriceTagExqController>();

    return GetBuilder<PriceTagExqController>(
      builder: (controller) {
        const itemsPerPage = 18;

        if (controller.data.isEmpty) {
          return Container(
            color: Colors.white,
            width: 794, // A4 width in pixels
            height: 1123, // A4 height in pixels
            alignment: Alignment.center,
            child: const Text(
              "No items found",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          );
        }

        // Calculate total pages
        final totalPages = (controller.data.length / itemsPerPage).ceil();
        controller.totalPages.value = totalPages;

        // Ensure `repaintKeys` match the number of pages
        controller.updateRepaintKeys();

        // Scroll Controller
        final ScrollController scrollController = ScrollController();

        // Listen to Scroll Events
        scrollController.addListener(() {
          final scrollOffset =
              scrollController.offset; // Current scroll position
          const pageHeight = 1123.0; // Fixed height of each A4 page
          final currentPage = (scrollOffset / pageHeight).floor() + 1;

          if (controller.currentPage.value != currentPage) {
            controller.currentPage.value = currentPage.clamp(1, totalPages);
          }
        });

        // Generate Content for All Pages
        List<Widget> allPages = [];
        for (int pageIndex = 0; pageIndex < totalPages; pageIndex++) {
          // Calculate data for each page
          final startIndex = pageIndex * itemsPerPage;
          final endIndex = (startIndex + itemsPerPage > controller.data.length)
              ? controller.data.length
              : startIndex + itemsPerPage;
          final pageData = controller.data.sublist(startIndex, endIndex);

          allPages.add(
            RepaintBoundary(
              key: controller.repaintKeys[pageIndex],
              child: Container(
                color: Colors.white,
                width: 794, // A4 width in pixels
                height: 1123, // A4 height in pixels
                padding: const EdgeInsets.all(8.0),
                margin: const EdgeInsets.only(
                    bottom: 10), // Add spacing between pages
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 8.0,
                    crossAxisSpacing: 8.0,
                    childAspectRatio: 8 / 5.5,
                  ),
                  itemCount: pageData.length,
                  itemBuilder: (context, index) {
                    final item = pageData[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: controller.pickedColor.value,
                      ),
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 5),
                        child: Column(
                          children: [
                            Container(
                              height: 35,
                              width: double.infinity,
                              color: Colors.white,
                              alignment: Alignment.center,
                              child: Text(
                                item.name,
                                style: const TextStyle(
                                  fontSize: 25,
                                  fontFamily: 'Alesend',
                                ),
                              ),
                            ),
                            Obx(() => WasNowPriceWidget(
                                  nowPrice: item.newPrice.toString(),
                                  wasPrice: item.oldPrice.toString(),
                                  strikeThrough: con.isStrikeThrogh.value,
                                )),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 5, right: 8),
                                child: Obx(
                                  () => Text(
                                    "*${con.smallText.value}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        }

        return Column(
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() => Text(
                        "Page ${controller.currentPage.value} of ${controller.totalPages.value}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      )),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          if (controller.currentPage.value > 1) {
                            controller.currentPage.value--;
                            scrollController.animateTo(
                              (controller.currentPage.value - 1) * 1123.0,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        child: const Text("Previous"),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          if (controller.currentPage.value < totalPages) {
                            controller.currentPage.value++;
                            scrollController.animateTo(
                              (controller.currentPage.value - 1) * 1123.0,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        child: const Text("Next"),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: controller.exportToPdf,
                        child: const Text("Print"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Continuous Scrolling Section
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  children: allPages,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class WasNowPriceWidget extends StatelessWidget {
  final String wasPrice;
  final String nowPrice;
  final bool strikeThrough;

  const WasNowPriceWidget(
      {super.key,
      required this.wasPrice,
      required this.nowPrice,
      required this.strikeThrough});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(top: 5, bottom: 5),
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(10)),
          alignment: Alignment.center,
          padding: const EdgeInsets.only(top: 25),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // WAS Section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        color: Colors.transparent,
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "WAS",
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                  height: 0.9,
                                  fontFamily: 'Habanera'),
                            ),
                            Text(
                              "AED",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        child: Text(
                          "$wasPrice.00",
                          style: TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                            fontFamily: 'Avenir',
                            decoration: strikeThrough == true
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            decorationColor: Colors.red,
                            decorationStyle: TextDecorationStyle.solid,
                            decorationThickness: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // NOW Section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        color: Colors.transparent,
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "NOW",
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                  height: 0.9,
                                  fontFamily: 'Habanera'),
                            ),
                            Text(
                              "AED",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        child: Text(
                          "$nowPrice.00",
                          style: const TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                              fontFamily: 'Avenir'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
