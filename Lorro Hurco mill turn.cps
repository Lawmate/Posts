/**
  Copyright (C) 2012-2023 by Autodesk, Inc.
  All rights reserved.

  Hurco Lathe post processor configuration.

  $Revision: 44083 1c5ad993a086f043365c6f9038d5d6561bad0ddd $
  $Date: 2023-08-12 05:06:32 $

  FORKID {E076A9BF-DF7D-4BB1-9A06-18CEBE661208}
*/

description = "Hurco Mill-Turning";
vendor = "Hurco";
vendorUrl = "https://www.hurco.com";
legal = "Copyright (C) 2012-2023 by Autodesk, Inc.";
certificationLevel = 2;
minimumRevision = 45702;

longDescription = "Post for turning on Hurco mills with Winmax. Post is based on using a tooling block where tools can alirned rotationally on a static turret or in parallel. All tools use the same machine offset. Tool comment must include values for x, y, z and a in that order and comma delimeted. x value denotes x distance from turret block centre (eg 'X175,'), y value is offset from centreline (eg 'Y0.015'), z value is distance from machine offset zero (g55) (eg 'Z54') and a value is counter-clockwise angle from 3 0'clock position in which the tool is aligned (eg 'A45')";
extension = "hnc";
programNameIsInteger = true;
setCodePage("ascii");

capabilities = CAPABILITY_TURNING | CAPABILITY_MILLING | CAPABILITY_MACHINE_SIMULATION;
tolerance = spatial(0.002, MM);

minimumChordLength = spatial(0.01, MM);
minimumCircularRadius = spatial(0.01, MM);
maximumCircularRadius = spatial(10000, MM);
minimumCircularSweep = toRad(0.01);
maximumCircularSweep = toRad(180);
allowHelicalMoves = false;
allowedCircularPlanes = 1 << PLANE_ZX; // allow ZX plane only

// user-defined properties
properties = {
  writeMachine: {
    title      : "Write machine",
    description: "Output the machine settings in the header of the code.",
    group      : "formats",
    type       : "boolean",
    value      : false,
    scope      : "post"
  },
  writeTools: {
    title      : "Write tool list",
    description: "Output a tool list in the header of the code.",
    group      : "formats",
    type       : "boolean",
    value      : false,
    scope      : "post"
  },
  separateWordsWithSpace: {
    title      : "Separate words with space",
    description: "Adds spaces between words if 'yes' is selected.",
    group      : "formats",
    type       : "boolean",
    value      : true,
    scope      : "post"
  },
  showSequenceNumbers: {
    title      : "Use sequence numbers",
    description: "'Yes' outputs sequence numbers on each block, 'Only on tool change' outputs sequence numbers on tool change blocks only, and 'No' disables the output of sequence numbers.",
    group      : "formats",
    type       : "enum",
    values     : [
      {title:"Yes", id:"true"},
      {title:"No", id:"false"},
      {title:"Only on tool change", id:"toolChange"}
    ],
    value: "true",
    scope: "post"
  },
  sequenceNumberStart: {
    title      : "Start sequence number",
    description: "The number at which to start the sequence numbers.",
    group      : "formats",
    type       : "integer",
    value      : 10,
    scope      : "post"
  },
  sequenceNumberIncrement: {
    title      : "Sequence number increment",
    description: "The amount by which the sequence number is incremented by in each block.",
    group      : "formats",
    type       : "integer",
    value      : 1,
    scope      : "post"
  },
  showNotes: {
    title      : "Show notes",
    description: "Writes operation notes as comments in the outputted code.",
    group      : "formats",
    type       : "boolean",
    value      : false,
    scope      : "post"
  },
  homePositionX: {
    title      : "G53 home position X",
    description: "G53 X-axis home position.",
    group      : "homePositions",
    type       : "number",
    value      : 0,
    scope      : "post"
  },
  homePositionZ: {
    title      : "G53 home position Z",
    description: "G53 Z-axis home position.",
    group      : "homePositions",
    type       : "number",
    value      : 0,
    scope      : "post"
  },
  safePositionMethod: {
    title      : "Safe Retracts",
    description: "Select your desired retract option.",
    group      : "homePositions",
    type       : "enum",
    values     : [
      {title:"G28", id:"G28"},
      {title:"G53", id:"G53"}
    ],
    value: "G28",
    scope: "post"
  },
  safePositionStyle: {
    title      : "Safe retract style",
    description: "Select your desired order for the axes to retract.",
    group      : "homePositions",
    type       : "enum",
    values     : [
      {title:"Only X", id:"X"},
      {title:"Only Z", id:"Z"},
      {title:"Both X then Z", id:"XZ"},
      {title:"Both Z then X", id:"ZX"},
      {title:"Both same line", id:"singleLineXZ"}
    ],
    value: "XZ",
    scope: "post"
  },
  optionalStop: {
    title      : "Optional stop",
    description: "Outputs optional stop code during when necessary in the code.",
    group      : "preferences",
    type       : "boolean",
    value      : true,
    scope      : "post"
  },
  isnc: {
    title      : "Use ISNC or BNC mode",
    description: "Selects between ISNC (ISO NC mode) and BNC (Basic NC mode).",
    group      : "formats",
    values     : [
      "Basic NC mode",
      "ISO NC mode"
    ],
    type : "boolean",
    value: true,
    scope: "post"
  },
  useRadius: {
    title      : "Radius arcs",
    description: "If yes is selected, arcs are outputted using radius values rather than IJK.",
    group      : "preferences",
    type       : "boolean",
    value      : false,
    scope      : "post"
  },
  maximumSpindleSpeed: {
    title      : "Max spindle speed",
    description: "Defines the maximum spindle speed allowed by your machines.",
    group      : "MillTurn",
    type       : "integer",
    range      : [
      0,
      999999999
    ],
    value: 9000,
    scope: "post"
  },
  useParametricFeed: {
    title      : "Parametric feed",
    description: "Specifies the feed value that should be output using a Q value.",
    group      : "preferences",
    type       : "boolean",
    value      : false,
    scope      : "post"
  },
  useCycles: {
    title      : "Use cycles",
    description: "Specifies if canned drilling cycles should be used.",
    group      : "preferences",
    type       : "boolean",
    value      : true,
    scope      : "post"
  },
  useRigidTapping: {
    title      : "Use rigid tapping",
    description: "Select 'Yes' to enable rigid tapping or 'No' to select tapping.",
    group      : "preferences",
    type       : "boolean",
    value      : false,
    scope      : "post"
  },
  useSimpleThread: {
    title      : "Use simple threading cycle",
    description: "Enable to output G92 simple threading cycle, disable to output G76 standard threading cycle.",
    group      : "preferences",
    type       : "boolean",
    value      : false,
    scope      : "post"
  },
  CSSinterval: {
    title      : "Interval between spindle speed moves to make radial move",
    description: "Make a radial move that equates to the spindle speed changing this amount. Minimum move is 0.001mm",
    group      : "MillTurn",
    type       : "integer",
    range      : [
                  0,
                  10000
                ],
    value      : 1000,
    scope      : "post"
  },
  blockCentreX: {
    title      : "Tool block centre X",
    description: "All tool positions are dimensioned from the centre point. This value is the distance from the work offset point.",
    group      : "MillTurn",
    type       : "number",
    range      : [
                  0,
                  10000
                ],
    value      : 120.25,
    scope      : "post"
  },
  blockCentreY: {
    title      : "Tool block centre Y",
    description: "All tool positions are dimensioned from the centre point. This value is the distance from the work offset point.",
    group      : "MillTurn",
    type       : "number",
    range      : [
                  0,
                  10000
                ],
    value      : 97.5,
    scope      : "post"
  },
  partToolNumber: {
    title      : "Part Tool Number",
    description: "This is the tool number that holds the part to be turned",
    group      : "MillTurn",
    type       : "integer",
    range      : [
                  1,
                  9999
                ],
    value      : 75,
    scope      : "post"
  }
};

groupDefinitions = {
  configuration: {title:"Configuration", description:"Machine options", order:0},
  preferences  : {title:"Preferences", description:"User preferences", order:1},
  homePositions: {title:"Home Positioning", collapsed:true, order:2},
  general      : {title:"General", collapsed:true, order:3},
  header       : {title:"Header", description:"NC file header", collapsed:true, order:4},
  MillTurn     : {title:"Mill Turn", description:"Mill turn post options", collapsed:false, order:5}
};

//Lorro variables

//Tool tip position is in line with turret centre, aligned to tool angle
// var turretCentreX = getProperty("blockCentreX");
// var turretCentreY = getProperty("blockCentreY");
// var turretCentreX = 120.25;
// var turretCentreY = 97.5;
//tool comment x value is distance of tool tip from turret centre, rotated by tool angle. It is always positive
//tool comment y value is equivalent to tool height offset, rotated by the tool angle.
//tool comment z is distance from tool tip to g55 zero (turret bottom surface)
var largeMove = 3; //distance move in x that deserves breaking up.
var adjustSpeedPerMove = false; //boolean flag for constant surface speed (CSS) mode.
                               //If true, it adjusts the speed per set distance interval for a move.
                               //If false, it creates a move based on a set change in speed.
var ODboring = false; //to turn ODs with a boring bar and spindle reversed, this inverts the X moves


var singleLineCoolant = false; // specifies to output multiple coolant codes in one line rather than in separate lines
// samples:
// {id: COOLANT_THROUGH_TOOL, on: 88, off: 89}
// {id: COOLANT_THROUGH_TOOL, on: [8, 88], off: [9, 89]}
var coolants = [
  {id:COOLANT_FLOOD, on:8},
  {id:COOLANT_MIST, on:7},
  {id:COOLANT_THROUGH_TOOL},
  {id:COOLANT_AIR},
  {id:COOLANT_AIR_THROUGH_TOOL},
  {id:COOLANT_SUCTION},
  {id:COOLANT_FLOOD_MIST},
  {id:COOLANT_FLOOD_THROUGH_TOOL},
  {id:COOLANT_OFF, off:9}
];

var permittedCommentChars = " ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,=_-";

var gFormat = createFormat({prefix:"G", decimals:1});
var mFormat = createFormat({prefix:"M", decimals:1});

var spatialFormat = createFormat({decimals:(unit == MM ? 3 : 4), forceDecimal:true});
var xFormat = createFormat({decimals:(unit == MM ? 3 : 4), forceDecimal:true, scale:1}); // radius mode
var yFormat = createFormat({decimals:(unit == MM ? 3 : 4), forceDecimal:true});
var zFormat = createFormat({decimals:(unit == MM ? 3 : 4), forceDecimal:true});
var iFormat = createFormat({decimals:(unit == MM ? 3 : 4), forceDecimal:true}); // radius mode
var rFormat = createFormat({decimals:(unit == MM ? 3 : 4), forceDecimal:true}); // radius
var feedFormat = createFormat({decimals:(unit == MM ? 3 : 4), forceDecimal:true});
var fprFormat = createFormat({decimals:(unit == MM ? 4 : 5), forceDecimal:true});
var fpmFormat = createFormat({decimals:(unit == MM ? 0 : 1), forceDecimal:true});
var pitchFormat = createFormat({decimals:6, forceDecimal:true});
var toolFormat = createFormat({decimals:0, width:4, zeropad:true});
var rpmFormat = createFormat({decimals:0});
var testFormat = createFormat({decimals:(unit == MM ? 3 : 4), forceDecimal:true});
var secFormat = createFormat({decimals:3, forceDecimal:true}); // seconds - range 0.001-99999.999
var taperFormat = createFormat({decimals:1, scale:DEG});
var threadP1Format = createFormat({decimals:0, forceDecimal:false, trim:false, width:6, zeropad:true});
var threadPQFormat = createFormat({decimals:(unit == MM ? 3 : 4), forceDecimal:false, trim:true});
var threadQFormat = createFormat({decimals:3, forceDecimal:true});
var threadQ1Format = createFormat({decimals:(unit == MM ? 3 : 4), forceDecimal:false});
var peckFormat = createFormat({decimals:(unit == MM ? 3 : 4), forceDecimal:true});
var integerFormat = createFormat({decimals:0, forceDecimal:false, trim:true});
// var peckFormat = createFormat({decimals:0, forceDecimal:false, trim:false, width:4, zeropad:true, scale:(unit == MM ? 1000 : 10000)});

var xOutput; // xOutput is defined in setDirectionX()
var yOutput = createVariable({onchange:function() {retracted[Y] = false;}, prefix:"Y"}, yFormat);
var zOutput = createVariable({onchange:function() {retracted[Z] = false;}, prefix:"Z"}, zFormat);
var feedOutput = createVariable({prefix:"F"}, feedFormat);
var pitchOutput = createVariable({prefix:"F", force:true}, pitchFormat);
var sOutput = createVariable({prefix:"S", force:true}, rpmFormat);
var pOutput = createVariable({prefix:"X"}, xFormat);
var qOutput = createVariable({prefix:"Y"}, yFormat);

// circular output
var kOutput = createReferenceVariable({prefix:"K"}, spatialFormat);
var iOutput; // iOutput is defined in setDirectionX()
var threadP1Output = createVariable({prefix:"P", force:true}, threadP1Format);
var threadP2Output = createVariable({prefix:"P", force:true}, threadPQFormat);
var threadQOutput = createVariable({prefix:"Q", force:true}, threadQ1Format);
var threadIOutput = createVariable({prefix:"I", force:true}, spatialFormat);
var threadROutput = createVariable({prefix:"R", force:true}, threadPQFormat);
var threadR2Output = createVariable({prefix:"R", force:true}, threadPQFormat);
var g92IOutput = createVariable({prefix:"I"}, zFormat); // no scaling
var g92QOutput = createVariable({prefix:"Q"}, threadQFormat);
var peckOutput = createVariable({prefix:"Q", force:true}, peckFormat);

var gMotionModal = createModal({}, gFormat); // modal group 1 // G0-G3, ...
var gPlaneModal = createModal({onchange:function () {gMotionModal.reset();}}, gFormat); // modal group 2 // G17-19
var gAbsIncModal = createModal({}, gFormat); // modal group 3 //G90-91
var gFeedModeModal = createModal({}, gFormat); // modal group 5 //G94-95
var gSpindleModeModal = createModal({}, gFormat); // modal group 5 // G96-97
var gUnitModal = createModal({}, gFormat); // modal group 6 // G20-21
var gCycleModal = createModal({}, gFormat); // modal group 9 // G81, ...

// fixed settings
var firstFeedParameter = 500;
var gotSecondarySpindle = true;
var gotTailStock = false;

var WARNING_WORK_OFFSET = 0;

var QCTP = 0;
var TURRET = 1;
var GANG = 2;

var FRONT = -1;
var REAR = 1;

// collected state
var sequenceNumber;
var currentWorkOffset;
var optionalSection = false;
var forceSpindleSpeed = false;
var tapping = false;
var activeMovements; // do not use by default
var currentFeedId;
var toolingData;
var previousToolingData;
var retracted = new Array(false, false, false); // specifies that the tool has been retracted to the safe plane
var fpmCode = 94;
var fprCode = 95;

function onPassThrough(text) {
    var commands = String(text).split(",");
    for (text in commands) {
      if(commands[text]==='front'){
        writeBlock(gFormat.format(53), gMotionModal.format(0), zOutput.format(0));
        writeBlock(gFormat.format(53), gMotionModal.format(0), xOutput.format(300), yOutput.format(405));
        // writeBlock(yOutput.format(333));
      }else{
        writeBlock(commands[text]);
      }
    }
  }

function getCode(code) {
  switch (code) {
  // case "PART_CATCHER_ON":
  // return mFormat.format(SPECIFY YOUR CODE HERE);
  // case "PART_CATCHER_OFF":
  // return mFormat.format(SPECIFY YOUR CODE HERE);
  // case "TAILSTOCK_ON":
  // return mFormat.format(SPECIFY YOUR CODE HERE);
  // case "TAILSTOCK_OFF":
  // return mFormat.format(SPECIFY YOUR CODE HERE);
  // case "ENGAGE_C_AXIS":
  // machineState.cAxisIsEngaged = true;
  // return cAxisEngageModal.format(UNSUPPORTED);
  // case "DISENGAGE_C_AXIS":
  // machineState.cAxisIsEngaged = false;
  // return cAxisEngageModal.format(UNSUPPORTED);
  // case "POLAR_INTERPOLATION_ON":
  // return gPolarModal.format(UNSUPPORTED);
  // case "POLAR_INTERPOLATION_OFF":
  // return gPolarModal.format(UNSUPPORTED);
  // case "STOP_LIVE_TOOL":
  // machineState.liveToolIsActive = false;
  // return mFormat.format(UNSUPPORTED);
  // case "STOP_MAIN_SPINDLE":
  // machineState.mainSpindleIsActive = false;
  // return mFormat.format(UNSUPPORTED);
  // case "STOP_SUB_SPINDLE":
  // machineState.subSpindleIsActive = false;
  // return mFormat.format(UNSUPPORTED);
  // case "START_LIVE_TOOL_CW":
  // machineState.liveToolIsActive = true;
  // return mFormat.format(UNSUPPORTED);
  // case "START_LIVE_TOOL_CCW":
  // machineState.liveToolIsActive = true;
  // return mFormat.format(UNSUPPORTED);
  case "START_MAIN_SPINDLE_CW":
    // machineState.mainSpindleIsActive = true;
    return mFormat.format(3);
  case "START_MAIN_SPINDLE_CCW":
    // machineState.mainSpindleIsActive = true;
    return mFormat.format(4);
  // case "START_SUB_SPINDLE_CW":
    // machineState.subSpindleIsActive = true;
    // return mFormat.format(UNSUPPORTED);
  // case "START_SUB_SPINDLE_CCW":
    // machineState.subSpindleIsActive = true;
    // return mFormat.format(UNSUPPORTED);
  // case "MAIN_SPINDLE_BRAKE_ON":
    // machineState.mainSpindleBrakeIsActive = true;
    // return cAxisBrakeModal.format(UNSUPPORTED);
  // case "MAIN_SPINDLE_BRAKE_OFF":
    // machineState.mainSpindleBrakeIsActive = false;
    // return cAxisBrakeModal.format(UNSUPPORTED);
  // case "SUB_SPINDLE_BRAKE_ON":
    // machineState.subSpindleBrakeIsActive = true;
    // return cAxisBrakeModal.format(UNSUPPORTED);
  // case "SUB_SPINDLE_BRAKE_OFF":
    // machineState.subSpindleBrakeIsActive = false;
    // return cAxisBrakeModal.format(UNSUPPORTED);
  case "FEED_MODE_UNIT_REV":
    return gFeedModeModal.format(fprCode);
  case "FEED_MODE_UNIT_MIN":
    return gFeedModeModal.format(fpmCode);
  case "CONSTANT_SURFACE_SPEED_ON":
    return gSpindleModeModal.format(96);
  case "CONSTANT_SURFACE_SPEED_OFF":
    return gSpindleModeModal.format(97);
  case "MAINSPINDLE_AIR_BLAST_ON":
    return mFormat.format(16);
  case "MAINSPINDLE_AIR_BLAST_OFF":
    return mFormat.format(17);
  // case "SUBSPINDLE_AIR_BLAST_ON":
    // return mFormat.format(UNSUPPORTED);
  // case "SUBSPINDLE_AIR_BLAST_OFF":
    // return mFormat.format(UNSUPPORTED);
  case "CLAMP_PRIMARY_CHUCK":
    return mFormat.format(getProperty("isnc") ? 69 : 14);
  case "UNCLAMP_PRIMARY_CHUCK":
    return mFormat.format(getProperty("isnc") ? 68 : 15);
  // case "CLAMP_SECONDARY_CHUCK":
    // return mFormat.format(UNSUPPORTED);
  // case "UNCLAMP_SECONDARY_CHUCK":
    // return mFormat.format(UNSUPPORTED);
  // case "SPINDLE_SYNCHRONIZATION_ON":
    // machineState.spindleSynchronizationIsActive = true;
    // return gSynchronizedSpindleModal.format(UNSUPPORTED);
  // case "SPINDLE_SYNCHRONIZATION_OFF":
    // machineState.spindleSynchronizationIsActive = false;
    // return gSynchronizedSpindleModal.format(UNSUPPORTED);
  case "START_CHIP_TRANSPORT":
    return mFormat.format(getProperty("isnc") ? 24 : 59);
  case "STOP_CHIP_TRANSPORT":
    return mFormat.format(getProperty("isnc") ? 25 : 61);
  // case "OPEN_DOOR":
    // return mFormat.format(UNSUPPORTED);
  // case "CLOSE_DOOR":
    // return mFormat.format(UNSUPPORTED);
  default:
    error(localize("Command " + code + " is not defined."));
    return 0;
  }
}

function isSpindleSpeedDifferent() {
  if (isFirstSection()) {
    return true;
  }
  if (getPreviousSection().getTool().clockwise != tool.clockwise) {
    return true;
  }
  if (tool.getSpindleMode() == SPINDLE_CONSTANT_SURFACE_SPEED) {
    if ((getPreviousSection().getTool().getSpindleMode() != SPINDLE_CONSTANT_SURFACE_SPEED) ||
        rpmFormat.areDifferent(getPreviousSection().getTool().surfaceSpeed, tool.surfaceSpeed)) {
      return true;
    }
  } else {
    if ((getPreviousSection().getTool().getSpindleMode() != SPINDLE_CONSTANT_SPINDLE_SPEED) ||
        rpmFormat.areDifferent(getPreviousSection().getTool().spindleRPM, spindleSpeed)) {
      return true;
    }
  }
  return false;
}

/**
  Writes the specified block.
*/
function writeBlock() {
  var text = formatWords(arguments);
  if (!text) {
    return;
  }
  if (getProperty("showSequenceNumbers") == "true") {
    if (optionalSection) {
      if (text) {
        writeWords("/", "N" + sequenceNumber, text);
      }
    } else {
      writeWords2("N" + sequenceNumber, arguments);
    }
    sequenceNumber += getProperty("sequenceNumberIncrement");
  } else {
    if (optionalSection) {
      writeWords2("/", arguments);
    } else {
      writeWords(arguments);
    }
  }
}

/**
  Writes the specified optional block.
*/
function writeOptionalBlock() {
  if (getProperty("showSequenceNumbers") == "true") {
    var words = formatWords(arguments);
    if (words) {
      writeWords("/", "N" + sequenceNumber, words);
      sequenceNumber += getProperty("sequenceNumberIncrement");
    }
  } else {
    writeWords2("/", arguments);
  }
}

function formatComment(text) {
  return "(" + filterText(String(text).toUpperCase(), permittedCommentChars).replace(/[()]/g, "") + ")";
}

/**
  Writes the specified block - used for tool changes only.
*/
function writeToolBlock() {
  var show = getProperty("showSequenceNumbers");
  setProperty("showSequenceNumbers", (show == "true" || show == "toolChange") ? "true" : "false");
  // writeBlock(arguments);
  setProperty("showSequenceNumbers", show);
}

/**
  Output a comment.
*/
function writeComment(text) {
  writeln(formatComment(text));
}

function onOpen() {
  if (getProperty("useRadius")) {
    maximumCircularSweep = toRad(90); // avoid potential center calculation errors for CNC
  }

  yOutput.disable();

  if (!getProperty("separateWordsWithSpace")) {
    setWordSeparator("");
  }

  sequenceNumber = getProperty("sequenceNumberStart");
  writeln("%");

  if (programName) {
    var programId;
    try {
      programId = getAsInt(programName);
    } catch (e) {
      error(localize("Program name must be a number."));
      return;
    }
    if (!((programId >= 1) && (programId <= 9999))) {
      error(localize("Program number is out of range."));
      return;
    }
    var oFormat = createFormat({width:4, zeropad:true, decimals:0});
    if (programComment) {
      writeln("O" + oFormat.format(programId) + " (" + filterText(String(programComment).toUpperCase(), permittedCommentChars) + ")");
    } else {
      writeln("O" + oFormat.format(programId));
    }
  } else {
    error(localize("Program name has not been specified."));
    return;
  }

  // dump machine configuration
  var vendor = machineConfiguration.getVendor();
  var model = machineConfiguration.getModel();
  var description = machineConfiguration.getDescription();

  if (getProperty("writeMachine") && (vendor || model || description)) {
    writeComment(localize("Machine"));
    if (vendor) {
      writeComment("  " + localize("vendor") + ": " + vendor);
    }
    if (model) {
      writeComment("  " + localize("model") + ": " + model);
    }
    if (description) {
      writeComment("  " + localize("description") + ": "  + description);
    }
  }

  if ((getNumberOfSections() > 0) && (getSection(0).workOffset == 0)) {
    for (var i = 0; i < getNumberOfSections(); ++i) {
      if (getSection(i).workOffset > 0) {
        error(localize("Using multiple work offsets is not possible if the initial work offset is 0."));
        return;
      }
    }
  }

  if (getProperty("writeTools")) {
    var zRanges = {};
    if (is3D()) {
      var numberOfSections = getNumberOfSections();
      for (var i = 0; i < numberOfSections; ++i) {
        var section = getSection(i);
        var zRange = section.getGlobalZRange();
        var tool = section.getTool();
        if (zRanges[tool.number]) {
          zRanges[tool.number].expandToRange(zRange);
        } else {
          zRanges[tool.number] = zRange;
        }
      }
    }

    var tools = getToolTable();
    if (tools.getNumberOfTools() > 0) {
      for (var i = 0; i < tools.getNumberOfTools(); ++i) {
        var tool = tools.getTool(i);
        var compensationOffset = tool.isTurningTool() ? tool.compensationOffset : tool.lengthOffset;
        var comment = "T" + toolFormat.format(tool.number * 100 + compensationOffset % 100) + " " +
          (tool.diameter != 0 ? "D=" + spatialFormat.format(tool.diameter) + " " : "") +
          (tool.isTurningTool() ? localize("NR") + "=" + spatialFormat.format(tool.noseRadius) : localize("CR") + "=" + spatialFormat.format(tool.cornerRadius)) +
          (tool.taperAngle > 0 && (tool.taperAngle < Math.PI) ? " " + localize("TAPER") + "=" + taperFormat.format(tool.taperAngle) + localize("deg") : "") +
          (zRanges[tool.number] ? " - " + localize("ZMIN") + "=" + spatialFormat.format(zRanges[tool.number].getMinimum()) : "") +
           " - " + localize(getToolTypeName(tool.type));
        writeComment(comment);
      }
    }
  }

  // absolute coordinates and feed per min
  // writeBlock(gAbsIncModal.format(90), gFormat.format(40), gFormat.format(80));
  writeBlock(gAbsIncModal.format(90), gFormat.format(17));

  switch (unit) {
  case IN:
    writeBlock(gUnitModal.format(20));
    break;
  case MM:
    writeBlock(gUnitModal.format(21));
    break;
  }

  //start chip auger
  writeBlock(mFormat.format(59));

  // writeBlock(gFormat.format(92), sOutput.format(getProperty("maximumSpindleSpeed")));

  onCommand(COMMAND_START_CHIP_TRANSPORT);
}

function onComment(message) {
  writeComment(message);
}

/** Force output of X, Y, and Z. */
function forceXYZ() {
  xOutput = null;
  yOutput.reset();
  zOutput.reset();
}

function forceFeed() {
  currentFeedId = undefined;
  feedOutput.reset();
}

/** Force output of X, Y, Z, and F on next output. */
function forceAny() {
  forceXYZ();
  forceFeed();
}

function forceThread() {
  forceFeed();
  g92IOutput.reset();
  g92QOutput.reset();
  gCycleModal.reset();
  forceXYZ();
}

function FeedContext(id, description, feed) {
  this.id = id;
  this.description = description;
  this.feed = feed;
}

function formatFeedMode(mode) {
  var fMode = (mode == FEED_PER_REVOLUTION) ? getCode("FEED_MODE_UNIT_REV") : getCode("FEED_MODE_UNIT_MIN");
  if (fMode) {
    if (mode == FEED_PER_REVOLUTION) {
      feedFormat = createFormat({inherit:fprFormat});
    } else {
      feedFormat = createFormat({inherit:fpmFormat});
    }
    feedOutput = createVariable({prefix:"F"}, feedFormat);
  }
  return fMode;
}

function getFeed(f) {
  if (activeMovements) {
    var feedContext = activeMovements[movement];
    if (feedContext != undefined) {
      if (!feedFormat.areDifferent(feedContext.feed, f)) {
        if (feedContext.id == currentFeedId) {
          return ""; // nothing has changed
        }
        forceFeed();
        currentFeedId = feedContext.id;
        return "F#" + (firstFeedParameter + feedContext.id);
      }
    }
    currentFeedId = undefined; // force Q feed next time
  }
  if (gFeedModeModal.getCurrent() == fprCode) {
    f = (fprFormat.format(f) <= 0) ? (Math.pow(10, fprFormat.getNumberOfDecimals() * -1)) : f;
  }
  return feedOutput.format(f); // use feed value
}

function initializeActiveFeeds() {
  activeMovements = new Array();
  var movements = currentSection.getMovements();
  var feedPerRev = currentSection.feedMode == FEED_PER_REVOLUTION;

  var id = 0;
  var activeFeeds = new Array();
  if (hasParameter("operation:tool_feedCutting")) {
    if (movements & ((1 << MOVEMENT_CUTTING) | (1 << MOVEMENT_LINK_TRANSITION) | (1 << MOVEMENT_EXTENDED))) {
      var feedContext = new FeedContext(id, localize("Cutting"), feedPerRev ? getParameter("operation:tool_feedCuttingRel") : getParameter("operation:tool_feedCutting"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_CUTTING] = feedContext;
      if (!hasParameter("operation:tool_feedTransition")) {
        activeMovements[MOVEMENT_LINK_TRANSITION] = feedContext;
      }
      activeMovements[MOVEMENT_EXTENDED] = feedContext;
    }
    ++id;
    if (movements & (1 << MOVEMENT_PREDRILL)) {
      feedContext = new FeedContext(id, localize("Predrilling"), feedPerRev ? getParameter("operation:tool_feedCuttingRel") : getParameter("operation:tool_feedCutting"));
      activeMovements[MOVEMENT_PREDRILL] = feedContext;
      activeFeeds.push(feedContext);
    }
    ++id;
  }

  if (hasParameter("operation:finishFeedrate")) {
    if (movements & (1 << MOVEMENT_FINISH_CUTTING)) {
      var finishFeedrateRel;
      if (hasParameter("operation:finishFeedrateRel")) {
        finishFeedrateRel = getParameter("operation:finishFeedrateRel");
      } else if (hasParameter("operation:finishFeedratePerRevolution")) {
        finishFeedrateRel = getParameter("operation:finishFeedratePerRevolution");
      }
      var feedContext = new FeedContext(id, localize("Finish"), feedPerRev ? finishFeedrateRel : getParameter("operation:finishFeedrate"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_FINISH_CUTTING] = feedContext;
    }
    ++id;
  } else if (hasParameter("operation:tool_feedCutting")) {
    if (movements & (1 << MOVEMENT_FINISH_CUTTING)) {
      var feedContext = new FeedContext(id, localize("Finish"), feedPerRev ? getParameter("operation:tool_feedCuttingRel") : getParameter("operation:tool_feedCutting"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_FINISH_CUTTING] = feedContext;
    }
    ++id;
  }

  if (hasParameter("operation:tool_feedEntry")) {
    if (movements & (1 << MOVEMENT_LEAD_IN)) {
      var feedContext = new FeedContext(id, localize("Entry"), feedPerRev ? getParameter("operation:tool_feedEntryRel") : getParameter("operation:tool_feedEntry"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_LEAD_IN] = feedContext;
    }
    ++id;
  }

  if (hasParameter("operation:tool_feedExit")) {
    if (movements & (1 << MOVEMENT_LEAD_OUT)) {
      var feedContext = new FeedContext(id, localize("Exit"), feedPerRev ? getParameter("operation:tool_feedExitRel") : getParameter("operation:tool_feedExit"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_LEAD_OUT] = feedContext;
    }
    ++id;
  }

  if (hasParameter("operation:noEngagementFeedrate")) {
    if (movements & (1 << MOVEMENT_LINK_DIRECT)) {
      var feedContext = new FeedContext(id, localize("Direct"), feedPerRev ? getParameter("operation:noEngagementFeedrateRel") : getParameter("operation:noEngagementFeedrate"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_LINK_DIRECT] = feedContext;
    }
    ++id;
  } else if (hasParameter("operation:tool_feedCutting") &&
             hasParameter("operation:tool_feedEntry") &&
             hasParameter("operation:tool_feedExit")) {
    if (movements & (1 << MOVEMENT_LINK_DIRECT)) {
      var feedContext = new FeedContext(
        id,
        localize("Direct"),
        Math.max(
          feedPerRev ? getParameter("operation:tool_feedCuttingRel") : getParameter("operation:tool_feedCutting"),
          feedPerRev ? getParameter("operation:tool_feedEntryRel") : getParameter("operation:tool_feedEntry"),
          feedPerRev ? getParameter("operation:tool_feedExitRel") : getParameter("operation:tool_feedExit")
        )
      );
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_LINK_DIRECT] = feedContext;
    }
    ++id;
  }

  if (hasParameter("operation:reducedFeedrate")) {
    if (movements & (1 << MOVEMENT_REDUCED)) {
      var feedContext = new FeedContext(id, localize("Reduced"), feedPerRev ? getParameter("operation:reducedFeedrateRel") : getParameter("operation:reducedFeedrate"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_REDUCED] = feedContext;
    }
    ++id;
  }

  if (hasParameter("operation:tool_feedRamp")) {
    if (movements & ((1 << MOVEMENT_RAMP) | (1 << MOVEMENT_RAMP_HELIX) | (1 << MOVEMENT_RAMP_PROFILE) | (1 << MOVEMENT_RAMP_ZIG_ZAG))) {
      var feedContext = new FeedContext(id, localize("Ramping"), feedPerRev ? getParameter("operation:tool_feedRampRel") : getParameter("operation:tool_feedRamp"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_RAMP] = feedContext;
      activeMovements[MOVEMENT_RAMP_HELIX] = feedContext;
      activeMovements[MOVEMENT_RAMP_PROFILE] = feedContext;
      activeMovements[MOVEMENT_RAMP_ZIG_ZAG] = feedContext;
    }
    ++id;
  }
  if (hasParameter("operation:tool_feedPlunge")) {
    if (movements & (1 << MOVEMENT_PLUNGE)) {
      var feedContext = new FeedContext(id, localize("Plunge"), feedPerRev ? getParameter("operation:tool_feedPlungeRel") : getParameter("operation:tool_feedPlunge"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_PLUNGE] = feedContext;
    }
    ++id;
  }
  if (true) { // high feed
    if ((movements & (1 << MOVEMENT_HIGH_FEED)) || (highFeedMapping != HIGH_FEED_NO_MAPPING)) {
      var feed;
      if (hasParameter("operation:highFeedrateMode") && getParameter("operation:highFeedrateMode") != "disabled") {
        feed = getParameter("operation:highFeedrate");
      } else {
        feed = this.highFeedrate;
      }
      var feedContext = new FeedContext(id, localize("High Feed"), feed);
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_HIGH_FEED] = feedContext;
      activeMovements[MOVEMENT_RAPID] = feedContext;
    }
    ++id;
  }
  if (hasParameter("operation:tool_feedTransition")) {
    if (movements & (1 << MOVEMENT_LINK_TRANSITION)) {
      var feedContext = new FeedContext(id, localize("Transition"), getParameter("operation:tool_feedTransition"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_LINK_TRANSITION] = feedContext;
    }
    ++id;
  }

  for (var i = 0; i < activeFeeds.length; ++i) {
    var feedContext = activeFeeds[i];
    writeBlock("#" + (firstFeedParameter + feedContext.id) + "=" + feedFormat.format(feedContext.feed), formatComment(feedContext.description));
  }
}

function getSpindle() {
  if (getNumberOfSections() == 0) {
    return SPINDLE_PRIMARY;
  }
  if (getCurrentSectionId() < 0) {
    return getSection(getNumberOfSections() - 1).spindle == 0;
  }
  if (currentSection.getType() == TYPE_TURNING) {
    return currentSection.spindle;
  } else {
    if (isSameDirection(currentSection.workPlane.forward, new Vector(0, 0, 1))) {
      return SPINDLE_PRIMARY;
    } else if (isSameDirection(currentSection.workPlane.forward, new Vector(0, 0, -1))) {
      if (!gotSecondarySpindle) {
        error(localize("Secondary spindle is not available."));
      }
      return SPINDLE_SECONDARY;
    } else {
      return SPINDLE_PRIMARY;
    }
  }
}

function ToolingData(_tool) {
  switch (_tool.turret) {
  // Positional Turret
  case 0:
    this.tooling = TURRET;
    this.toolPost = REAR;
    break;
  // QCTP X-
  case 101:
    this.tooling = QCTP;
    this.toolPost = FRONT;
    break;
  // QCTP X+
  case 102:
    this.tooling = QCTP;
    this.toolPost = REAR;
    break;
  // Gang Tooling X-
  case 103:
    this.tooling = GANG;
    this.toolPost = FRONT;
    break;
  // Gang Tooling X+
  case 104:
    this.tooling = GANG;
    this.toolPost = REAR;
    break;
  default:
    error(localize("Turret number must be 0 (main turret), 101 (QCTP X-), 102 (QCTP X+, 103 (gang tooling X-), or 104 (gang tooling X+)."));
    break;
  }
  this.number = _tool.number;
  this.comment = _tool.comment;
  this.toolLength = _tool.bodyLength;
  // HSMWorks returns 0 in tool.bodyLength
  if ((tool.bodyLength == 0) && hasParameter("operation:tool_bodyLength")) {
    this.toolLength = getParameter("operation:tool_bodyLength");
  }
}

function setDirectionX() {
  xFormat.setScale(toolingData.toolPost == FRONT ? Math.abs(xFormat.getScale()) * -1 : Math.abs(xFormat.getScale()));
  iFormat.setScale(toolingData.toolPost == FRONT ? Math.abs(iFormat.getScale()) * -1 : Math.abs(iFormat.getScale()));
  xOutput = createVariable({onchange:function() {retracted[X] = false;}, prefix:"X"}, xFormat);
  iOutput = createReferenceVariable({prefix:"I"}, iFormat);
}
/*
A rotation: camX stays the same, camY = cosMachineY; sinMachineZ, camZ = sinMachineY; cosMachineZ
ArotX = camX, ArotY = cosCamY+sinCamZ, ArotZ = sinCamY+cosCamZ

*/
function getMoveX( camValX ){
  // Converts the normal lathe x axis moves into mill bed x axis moves.
  // It does this by rotating the moves around the turret centre position.
  //inverts x moves if OD boring
  var xNum = ODboring ? Number( -camValX ) : Number( camValX );
  // writeComment(xNum);
  var xturretOffset = ( xNum + tool.offsetx ) * Math.cos ( Math.PI * 2 * ( tool.offseta / 360 ) );
  //Applies tool height offset (equivalent to y axis in lathe) off rotated axis
  var xToolHeightOffset = tool.offsety * Math.cos ( Math.PI * 2 * ( ( tool.offseta < 270 ? tool.offseta + 90 : tool.offseta + 90 -360 ) / 360 ) );
  var x = getProperty("blockCentreX") + xturretOffset + xToolHeightOffset;
  
  // writeComment(getProperty("blockCentreX")*2);
  return xOutput.format(x);

}

function getMoveY( camValX ){
  //Same as the x axis, but generates y positions.
  //When the tool rotation is 0 and y is 0, there are no y axis moves.
  //lathe x axis moves are fed into this function, to return mill bed y axis moves.
  //inverts x moves if OD boring
  var xNum = ODboring ? Number( -camValX ) : Number( camValX );
  var yturretOffset = ( xNum + tool.offsetx ) * Math.sin ( Math.PI * 2 * ( tool.offseta / 360 ) );
  var yToolHeightOffset = tool.offsety * Math.sin ( Math.PI * 2 * ( ( tool.offseta < 270 ? tool.offseta + 90 : tool.offseta + 90 -360 ) / 360 ) );
  var y = getProperty("blockCentreY") + yturretOffset + yToolHeightOffset;
  return qOutput.format(y);

}

function getMoveZ( camValZ ){
  //Z axis off set for each tool
  var z = camValZ + tool.offsetz;
  return zOutput.format(z);
}

function getCSS( radVal ){
  //function to calculate the spindle speed based on the destined radius and the surface speed defined for the tool
  var maximumSpindleSpeed = (tool.maximumSpindleSpeed > 0) ? Math.min(tool.maximumSpindleSpeed, getProperty("maximumSpindleSpeed")) : getProperty("maximumSpindleSpeed");
  var idealSpindleSpeed = tool.surfaceSpeed / ( Math.PI * 2 * Math.abs( radVal ) );
  var newSpindleSpeed = ( idealSpindleSpeed < maximumSpindleSpeed ) ? idealSpindleSpeed : maximumSpindleSpeed;
  return newSpindleSpeed;

}

function getCSSmove( speedVal ){
  //function to calculate the x move based on the destined spindle speed and the surface speed defined for the tool
  // var maximumSpindleSpeed = (tool.maximumSpindleSpeed > 0) ? Math.min(tool.maximumSpindleSpeed, getProperty("maximumSpindleSpeed")) : getProperty("maximumSpindleSpeed");
  // var idealSpindleSpeed = tool.surfaceSpeed / ( Math.PI * 2 * Math.abs( radVal ) );
  // var newSpindleSpeed = ( idealSpindleSpeed < maximumSpindleSpeed ) ? idealSpindleSpeed : maximumSpindleSpeed;
  var radiusPos = tool.surfaceSpeed / ( speedVal * Math.PI * 2 );
  return radiusPos;
}

function getCSSFeed( speedVal ){
  //function to calculate the x move based on the destined spindle speed and the surface speed defined for the tool
 var feedVal = tool.surfaceSpeed / ( speedVal * Math.PI * 2 );
  return feedVal;
}

function getLiveTool(CamX, CamY, CamZ, toolA, toolC){

  var x1 = CamX;
  var y1 = (Math.cos((toolA*Math.PI)/180)*CamY)-(Math.sin((toolA*Math.PI)/180)*CamZ);
  var z1 = (Math.sin((toolA*Math.PI)/180)*CamZ)+(Math.cos((toolA*Math.PI)/180)*CamY);

  var x2 = (Math.cos((toolC*Math.PI)/180)*x1)-(Math.sin((toolC*Math.PI)/180)*x1);
  var y2 = (Math.sin((toolC*Math.PI)/180)*y1)+(Math.cos((toolC*Math.PI)/180)*y1);
  var z2 = z1;

  var outX = x2 + tool.offsetx;
  var outY = y2 + tool.offsety;
  var outZ = z2 + tool.offsetz;

  return{
    liveRotX:outX,
    liveRotY:outY,
    liveRotZ:outZ
  }
}

function movementComment(){
  if(movement == MOVEMENT_CUTTING){
    writeComment(movement + " MOVEMENT_CUTTING");
  }else if(movement == MOVEMENT_EXTENDED){
    writeComment(movement + " MOVEMENT_EXTENDED");
  }else if(movement == MOVEMENT_FINISH_CUTTING){
    writeComment(movement + " MOVEMENT_FINISH_CUTTING");
  }else if(movement == MOVEMENT_HIGH_FEED){
    writeComment(movement + " MOVEMENT_HIGH_FEED");
  }else if(movement == MOVEMENT_LEAD_IN){
    writeComment(movement + " MOVEMENT_LEAD_IN");
  }else if(movement == MOVEMENT_LEAD_OUT){
    writeComment(movement + " MOVEMENT_LEAD_OUT");
  }else if(movement == MOVEMENT_LINK_DIRECT){
    writeComment(movement + " MOVEMENT_LINK_DIRECT");
  }else if(movement == MOVEMENT_LINK_TRANSITION){
    writeComment(movement + " MOVEMENT_LINK_TRANSITION");
  }else if(movement == MOVEMENT_PLUNGE){
    writeComment(movement + " MOVEMENT_PLUNGE");
  }else if(movement == MOVEMENT_PREDRILL){
    writeComment(movement + " MOVEMENT_PREDRILL");
  }else if(movement == MOVEMENT_RAMP){
    writeComment(movement + " MOVEMENT_RAMP");
  }else if(movement == MOVEMENT_RAMP_HELIX){
    writeComment(movement + " MOVEMENT_RAMP_HELIX");
  }else if(movement == MOVEMENT_RAMP_PROFILE){
    writeComment(movement + " MOVEMENT_RAMP_PROFILE");
  }else if(movement == MOVEMENT_RAMP_ZIG_ZAG){
    writeComment(movement + " MOVEMENT_RAMP_ZIG_ZAG");
  }else if(movement == MOVEMENT_RAPID){
    writeComment(movement + " MOVEMENT_RAPID");
  }else if(movement == MOVEMENT_REDUCED){
    writeComment(movement + " MOVEMENT_REDUCED");
  }

}

var isMilling = false;
var liveTool = false;

function onSection() {
  if (currentSection.getType() != TYPE_TURNING) {
    if (!hasParameter("operation-strategy") || (getParameter("operation-strategy") != "drill")) {
      if (currentSection.getType() == TYPE_MILLING) {
        isMilling = true;
        // error(localize("Milling toolpath is not supported yo yo."));
      } else {
        // error(localize("Non-turning toolpath is not supported."));
      }
      // return;
    }
  }else{
    isMilling = false;
  }

  var forceToolAndRetract = optionalSection && !currentSection.isOptional();
  optionalSection = currentSection.isOptional();

  var turning = (currentSection.getType() == TYPE_TURNING);

  var insertToolCall = forceToolAndRetract || isFirstSection() ||
    currentSection.getForceToolChange && currentSection.getForceToolChange() ||
    (tool.number != getPreviousSection().getTool().number) ||
    (tool.compensationOffset != getPreviousSection().getTool().compensationOffset) ||
    (tool.diameterOffset != getPreviousSection().getTool().diameterOffset) ||
    (tool.lengthOffset != getPreviousSection().getTool().lengthOffset);

  var newSpindle = isFirstSection() ||
    (getPreviousSection().spindle != currentSection.spindle);
  var newWorkOffset = isFirstSection() ||
    (getPreviousSection().workOffset != currentSection.workOffset); // work offset changes

  // determine which tooling holder is used
  if (!isFirstSection()) {
    previousToolingData = toolingData;
  }
  toolingData = new ToolingData(tool);
  toolingData.operationComment = "";
  if (hasParameter("operation-comment")) {
    toolingData.operationComment = getParameter("operation-comment");
  }
  toolingData.toolChange = insertToolCall;
  if (isFirstSection()) {
    previousToolingData = toolingData;
  }

  setDirectionX();

  if (insertToolCall || newSpindle || newWorkOffset) {
    // retract to safe plane
    if (!isFirstSection() && insertToolCall) {
      onCommand(COMMAND_COOLANT_OFF);
    }
    writeRetract();
    forceXYZ();
  }
  
  //Load the work holding tool
  writeBlock("T" + toolFormat.format(getProperty("partToolNumber")) + " " + mFormat.format(6));

  writeln("");

  if (hasParameter("operation-comment")) {
    var comment = getParameter("operation-comment");
    if (comment) {
      writeComment(comment);
    }
  }
  // if (hasParameter("operation-strategy")) {
  //   var profile = getParameter("operation-strategy");
  //   if (profile==='turningProfileRoughing') {
  //   if (getParameter("operation-strategy")==='turningProfileRoughing') {
  //     writeComment(profile);
  //   }
  // }
  // writeBlock(gFormat.format(53), gFormat.format(0) + " Z0");
  // currentWorkOffset = undefined;

  if (getProperty("showNotes") && hasParameter("notes")) {
    var notes = getParameter("notes");
    if (notes) {
      var lines = String(notes).split("\n");
      var r1 = new RegExp("^[\\s]+", "g");
      var r2 = new RegExp("[\\s]+$", "g");
      for (var line in lines) {
        var comment = lines[line].replace(r1, "").replace(r2, "");
        if (comment) {
          writeComment(comment);
        }
      }
    }
  }
  var isRoughing = false;
  if (tool.comment) {
    // var xoff = /(?:x)([0-9]+)/.test(tool.comment);
    var data;
    if((tool.comment).startsWith('livetool')){
      var temp = new Array;
      temp = (tool.comment).split('livetool ');
      data = temp[1];
      liveTool = true;
    }else{
      data = tool.comment;
    }

    var vals = data.split(',');
    var thenum = new Array;
    for(i in vals){
        thenum[i] = vals[i].replace(/^\s[A-z]|[A-z]+/, '');
    }
    tool.offsetx=Number(thenum[0]);
    tool.offsety=Number(thenum[1]);
    tool.offsetz=Number(thenum[2]);
    tool.offseta=Number(thenum[3]);
    if(thenum.length>4)tool.offsetc=Number(thenum[4]);
    writeComment(tool.comment);
    writeComment("x is: " + tool.offsetx);
    writeComment("y is: " + tool.offsety);
    writeComment("z is: " + tool.offsetz);
    writeComment("A rotation angle is: " + tool.offseta);
    if(thenum.length>4)writeComment("C rotation angle is: " + tool.offsetc);
    // if(currentSection.strategy==="TURNINGPROFILEROUGHING"){
      // if(currentSection.checkGroup(STRATEGY_ROUGHING, STRATEGY_TURNING)){
    if (getParameter("operation-strategy")==='turningProfileRoughing') {
      writeComment(getParameter('operation:isRoughingStrategy'));
      isRoughing = true;
    }
    writeComment(2*(Math.abs(Math.max(getParameter("stock-lower-x"),getParameter("stock-lower-y")))));

    if(hasParameter('operation:tool_type')){
      if(getParameter('operation:tool_type')==='turning boring' && !getParameter('operation:tool_clockwise')){
        writeComment("OD turning with boring bar");
        ODboring = true;
      }else{
        ODboring = false;
      }
    }

    if(!ODboring && hasParameter('operation:tool_holderType')){
      if(getParameter('operation:tool_holderType')==='groove internal' && !getParameter('operation:tool_clockwise')){
        writeComment("OD turning with boring bar");
        ODboring = true;
      }else{
        ODboring = false;
      }
    }
  }

  if (insertToolCall) {
    // onCommand(COMMAND_COOLANT_OFF);

    if (!isFirstSection() && getProperty("optionalStop")) {
      onCommand(COMMAND_OPTIONAL_STOP);
    }

    if (tool.number > 99) {
      warning(localize("Tool number exceeds maximum value."));
    }

    if ((toolingData.tooling == QCTP) || tool.getManualToolChange()) {
      var comment = formatComment(localize("CHANGE TO T") + tool.number + " " + localize("ON") + " " +
        localize((toolingData.toolPost == REAR) ? "REAR TOOL POST" : "FRONT TOOL POST"));
      writeBlock(mFormat.format(0), comment);
    }

    var compensationOffset = (tool.isTurningTool()||tool.isDrill()) ? tool.compensationOffset : tool.lengthOffset;
    if (compensationOffset > 999) {
      error(localize("Compensation offset is out of range."));
      return;
    }
    writeToolBlock("T" + toolFormat.format(tool.number * 100 + compensationOffset));
    if (tool.comment) {
        // var xoff = /(?:x)([0-9]+)/.test(tool.comment);
      //   var vals = (tool.comment).split(',');
      //   var thenum = new Array;
      //   for(i in vals){
      //       thenum[i] = vals[i].replace(/^\s[A-z]|[A-z]+/, '');
      //   }
      // tool.offsetx=Number(thenum[0]);
      // tool.offsety=Number(thenum[1]);
      // tool.offsetz=Number(thenum[2]);
      // tool.offseta=Number(thenum[3]);
      // writeComment(tool.comment);
      // writeComment("x is: " + tool.offsetx);
      // writeComment("y is: " + tool.offsety);
      // writeComment("z is: " + tool.offsetz);
      // writeComment("rotation angle is: " + tool.offseta);
    }
  }

  // wcs
  if (insertToolCall) { // force work offset when changing tool
    currentWorkOffset = undefined;
  }
  var workOffset = currentSection.workOffset;
  if (workOffset == 0) {
    warningOnce(localize("Work offset has not been specified. Using G54 as WCS."), WARNING_WORK_OFFSET);
    workOffset = 1;
  }
  if (workOffset > 0) {
    if (getProperty("isnc")) {
      if (workOffset > 6) {
        var p = workOffset - 6; // 1->...
        if (p > 93) {
          error(localize("Work offset out of range."));
          return;
        } else {
          if (workOffset != currentWorkOffset) {
            writeBlock(gFormat.format(54.1), "P" + p); // G54.1P
            currentWorkOffset = workOffset;
          }
        }
      } else {
        if (workOffset != currentWorkOffset) {
          writeBlock(gFormat.format(53 + workOffset)); // G54->G59
          currentWorkOffset = workOffset;
        }
      }
    } else {
      if (workOffset > 99) {
        error(localize("Work offset out of range."));
      } else {
        if (workOffset != currentWorkOffset) {
          writeBlock("E" + workOffset); // E1->99
          currentWorkOffset = workOffset;
        }
      }
    }
  }

  // set coolant after we have positioned at Z
  setCoolant(tool.coolant);

  forceAny();
  gMotionModal.reset();

  gFeedModeModal.reset();
  writeBlock(formatFeedMode(currentSection.feedMode));

  if (gotTailStock) {
    writeBlock(getCode(currentSection.tailstock ? "TAILSTOCK_ON" : "TAILSTOCK_OFF"));
  }
  // writeBlock(mFormat.format(clampPrimaryChuck ? x : x));
  // writeBlock(mFormat.format(clampSecondaryChuck ? x : x));

  tapping = hasParameter("operation:cycleType") &&
    ((getParameter("operation:cycleType") == "tapping") ||
    (getParameter("operation:cycleType") == "right-tapping") ||
    (getParameter("operation:cycleType") == "left-tapping") ||
    (getParameter("operation:cycleType") == "tapping-with-chip-breaking"));
  var initialPosition = getFramePosition(currentSection.getInitialPosition());

  var spindleChanged = forceSpindleSpeed || newSpindle || isSpindleSpeedDifferent();
  if (insertToolCall || spindleChanged) {
    forceSpindleSpeed = false;
    if(getParameter("stock-type")==="cylinder"){
      var stockRad = {x:Number(getParameter("stock-diameter"))/2};
      writeComment(typeof(stockRad));
      startSpindle(false, true, stockRad);

    }else if(getParameter("stock-type")==="custom"){
      var stockRad = {x:Number(Math.abs(Math.max(getParameter("stock-lower-x"),getParameter("stock-lower-y"))))};
      // writeComment(stockRad);
      // writeComment(typeof(stockRad));
      startSpindle(false, true, stockRad);
    }else if(getParameter("stock-type")==="box"){
      //get largest width value from centre point
      var stockX = Math.max(Math.abs(Number(getParameter("stock-lower-x"))), Math.abs(Number(getParameter("stock-upper-x"))));
      //get largest height value from centre point
      var stockY = Math.max(Math.abs(Number(getParameter("stock-lower-y"))), Math.abs(Number(getParameter("stock-upper-y"))));
      //Calculate diagonal from centre point
      var stockDiag = Math.pow( ( ( stockX * stockX ) + ( stockY * stockY ) ), 0.5);
      //create object to send to startSpindle function
      var stockRad = {x:stockDiag};
      // writeComment(stockRad);
      // writeComment(typeof(stockRad));
      startSpindle(false, true, stockRad);
    }
  }

  setRotation(currentSection.workPlane);

  if (currentSection.partCatcher) {
    engagePartCatcher(true);
  }

  gMotionModal.reset();

  if ((insertToolCall || tool.getSpindleMode() == SPINDLE_CONSTANT_SURFACE_SPEED) && !isMilling) {

    var x,y,z;

    if( !isMilling ){
      x = getMoveX(initialPosition.x);
      y = getMoveY(initialPosition.x);
      z = getMoveZ(initialPosition.z);
    }else{
      x = initialPosition.x;
      y = initialPosition.y;
      z = initialPosition.z;
    }
    writeBlock(gMotionModal.format(0), z);
    // writeComment(xOutput.format(getMoveX(initialPosition.x)));
    // writeComment(getMoveX(initialPosition.x));
    // writeComment(initialPosition.x);
    // writeComment(y);
    writeBlock(gMotionModal.format(0), x, y);

    gMotionModal.reset();
  }

  // enable SFM spindle speed
  if (tool.getSpindleMode() == SPINDLE_CONSTANT_SURFACE_SPEED) {
    // startSpindle(false, false);
  }

  if (getProperty("useParametricFeed") &&
      hasParameter("operation-strategy") &&
      (getParameter("operation-strategy") != "drill") && // legacy
      !(currentSection.hasAnyCycle && currentSection.hasAnyCycle())) {
    if (!insertToolCall &&
        activeMovements &&
        (getCurrentSectionId() > 0) &&
        ((getPreviousSection().getPatternId() == currentSection.getPatternId()) && (currentSection.getPatternId() != 0))) {
      // use the current feeds
    } else {
      initializeActiveFeeds();
    }
  } else {
    activeMovements = undefined;
  }

  if (insertToolCall || (retracted[X] || retracted[Z])) {
    gPlaneModal.reset();
  }

}

function onDwell(seconds) {
  if (seconds > 99999.999) {
    warning(localize("Dwelling time is out of range."));
  }
  var _seconds = clamp(0.001, seconds, 99999.999);
  var tmpFeedMode = gFeedModeModal.getCurrent();
  writeBlock(formatFeedMode(FEED_PER_MINUTE), gFormat.format(4), (!getProperty("isnc") ? "U" : "F") + secFormat.format(_seconds));
  writeBlock(gFeedModeModal.format(tmpFeedMode));
}

var pendingRadiusCompensation = -1;

function onRadiusCompensation() {
  pendingRadiusCompensation = radiusCompensation;
}

var hasRapided = false;

function onRapid(_x, _y, _z) {
  // don't output starts for threading
  if (threadNumber > 0 &&
    (!getProperty("isnc") ||
    getProperty("useSimpleThread") ||
    (hasParameter("operation:infeedMode") && (getParameter("operation:infeedMode") == "alternate")))) {
    return;
  }
  if(isMilling){
    if(liveTool){
      var transform = getLiveTool(_x, _y, _z, tool.offseta, tool.offsetc);
      var x = pOutput.format(transform.liveRotX);
      var y = qOutput.format(transform.liveRotY);
      var z = zOutput.format(transform.liveRotZ);
    }else{
      var x = pOutput.format(_x);
      var y = qOutput.format(_y);
      var z = zOutput.format(_z);
    }
  }else{
    var x = getMoveX(_x);
    var y = getMoveY(_x);
    var z = getMoveZ(_z);
  }
  // var x = isMilling? pOutput.format(_x) : getMoveX(_x);
  // var y = isMilling? qOutput.format(_y) : getMoveY(_x);
  // var z = isMilling? zOutput.format(_z) : getMoveZ(_z);
  if (x || y || z) {
    if (pendingRadiusCompensation >= 0) {
      pendingRadiusCompensation = -1;
      switch (radiusCompensation) {
      case RADIUS_COMPENSATION_LEFT:
        writeBlock(gMotionModal.format(0), gFormat.format(41), x, y, z);
        break;
      case RADIUS_COMPENSATION_RIGHT:
        writeBlock(gMotionModal.format(0), gFormat.format(42), x, y, z);
        break;
      default:
        writeBlock(gMotionModal.format(0), gFormat.format(40), x, y, z);
      }
    } else {
      writeBlock(gMotionModal.format(0), x, y, z);
    }
    forceFeed();
  }
  hasRapided = true;
}

var resetFeed = false;

function onLinear(_x, _y, _z, feed) {
  // don't output starts for threading
  if (threadNumber > 0 &&
      (!getProperty("isnc") ||
      getProperty("useSimpleThread") ||
      (hasParameter("operation:infeedMode") && (getParameter("operation:infeedMode") == "alternate")))) {
    return;
  }
  if (isSpeedFeedSynchronizationActive()) {
    resetFeed = true;
    var threadPitch = getParameter("operation:threadPitch");
    var threadsPerInch = 1.0 / threadPitch; // per mm for metric
    // i think we need to force out G33 if we switch from I to K. This happens on fade thread end.
    var pitch = Math.abs(getCurrentPosition().x - x) > Math.abs(getCurrentPosition().z - z) ?
      "I" + pitchFormat.format(threadPitch * ((getCurrentPosition().x - x) / (getCurrentPosition().z - z))) :
      "K" + pitchFormat.format(threadPitch);
    writeBlock(gMotionModal.format(33), xOutput.format(_x), yOutput.format(_y), zOutput.format(_z), pitch);
    return;
  }
  if (resetFeed) {
    resetFeed = false;
    forceFeed();
  }
  if ( _x && tool.getSpindleMode() == SPINDLE_CONSTANT_SURFACE_SPEED ){
    var xDist = Math.abs( getCurrentPosition().x - _x );
    var zDist = Math.abs( getCurrentPosition().z - _z );
    var maximumSpindleSpeed = (tool.maximumSpindleSpeed > 0) ? Math.min(tool.maximumSpindleSpeed, getProperty("maximumSpindleSpeed")) : getProperty("maximumSpindleSpeed");
    // writeComment( "x distance " + xDist +", destination x " + _x + ", start x " + getCurrentPosition().x );
    // writeComment( "destination z " + _z + ", start z " + getCurrentPosition().z );
    // writeComment( "surface speed " + tool.surfaceSpeed );
    if( xDist > largeMove ){
      writeComment( "large x move" );
      var posOrNeg = ( _x < getCurrentPosition().x ) ? -largeMove : largeMove;
      var startX = getCurrentPosition().x;
      var startZ = getCurrentPosition().z;
      if(adjustSpeedPerMove ){
        var sections = Math.floor( xDist / largeMove );
        for( let i = 0; i < sections; i++ ){
          // writeComment( startX + ( posOrNeg * ( i + 1 ) ) );
          // writeComment( ( largeMove * posOrNeg * ( i + 1 ) ) );
          var increment = posOrNeg * ( i + 1 );
          var moveTemp = startX + ( increment );
          var tempX = getMoveX( moveTemp );
          var tempY = getMoveY( moveTemp );
          var tempZ = getMoveZ( startZ + ( ( Math.abs( increment ) / xDist ) * zDist ) );
          var tempF = getFeed(feed);
          var tempSpeed = getCSS( moveTemp );
          writeBlock( sOutput.format( tempSpeed ) );
          writeBlock(gMotionModal.format(isSpeedFeedSynchronizationActive() ? 32 : 1), tempX, tempY, tempZ, tempF);
        }
      }else{
        var speedInterval = getProperty("CSSinterval");
        startingSpeed = getCSS( startX );
        finishSpeed = getCSS( _x );
        var sections = Math.floor( Math.abs( startingSpeed - finishSpeed ) / speedInterval );
        // writeComment( "start " + startingSpeed + ", fin " + finishSpeed + ", sections " + sections + ", speed interval " + speedInterval );
        // writeComment( "start x " + startX );
        var getKeys = function(obj){
          var keys = [];
          for(var key in obj){
             keys.push(key);
          }
          return keys;
        }
        // writeComment(getKeys(tool));
        // writeComment(getParameter("operation:tool_feedCutting"));
        for( let i = 0; i < sections; i++ ){
          var increment = ( ( _x < getCurrentPosition().x ) ? speedInterval : -speedInterval ) * ( i + 1 );
          var speedTemp = startingSpeed + increment;
          var moveTemp = getCSSmove( speedTemp );
          var feedTemp = getCSSFeed( speedTemp );
          var tempX = getMoveX( moveTemp );
          var tempY = getMoveY( moveTemp );
          var tempZ = getMoveZ( startZ + ( ( Math.abs( increment ) / xDist ) * zDist ) );
          var tempF = getFeed(feed);
          // writeComment( "feed " + gFeedModeModal.getCurrent() );
          // writeComment( "feed " + ( speedTemp * feed ) );
          if( tempX || tempY ){
            writeBlock( sOutput.format( speedTemp ) );
            writeBlock(gMotionModal.format(isSpeedFeedSynchronizationActive() ? 32 : 1), tempX, tempY, tempZ, tempF);
          }
        }
      }
      if(hasRapided && (movement === MOVEMENT_CUTTING)){
        // movementComment();
        hasRapided = false;
        writeBlock( sOutput.format( getCSS( _x ) ) );
      }
    }else{
      ;
      // writeComment( "new speed " + newSpindleSpeed );
      if(hasRapided && (movement === MOVEMENT_CUTTING)){
        // movementComment();
        hasRapided = false;
        writeBlock( sOutput.format( getCSS( _x ) ) );
      }

      // movementComment();
      
    }
  }
  if(isMilling){
    if(liveTool){
      var transform = getLiveTool(_x, _y, _z, tool.offseta, tool.offsetc);
      var x = pOutput.format(transform.liveRotX);
      var y = qOutput.format(transform.liveRotY);
      var z = zOutput.format(transform.liveRotZ);
    }else{
      var x = pOutput.format(_x);
      var y = qOutput.format(_y);
      var z = zOutput.format(_z);
    }
  }else{
    var x = getMoveX(_x);
    var y = getMoveY(_x);
    var z = getMoveZ(_z);
  }
  var f = getFeed( feed );
  if (x || y || z) {
    if (pendingRadiusCompensation >= 0) {
      pendingRadiusCompensation = -1;
      switch (radiusCompensation) {
      case RADIUS_COMPENSATION_LEFT:
        writeBlock(gMotionModal.format(isSpeedFeedSynchronizationActive() ? 32 : 1), gFormat.format(41), x, y, z, f);
        break;
      case RADIUS_COMPENSATION_RIGHT:
        writeBlock(gMotionModal.format(isSpeedFeedSynchronizationActive() ? 32 : 1), gFormat.format(42), x, y, z, f);
        break;
      default:
        writeBlock(gMotionModal.format(isSpeedFeedSynchronizationActive() ? 32 : 1), gFormat.format(40), x, y, z, f);
      }
    } else {
      // writeComment("x is " + _x + ", circumference is " + ( _x * 2 * Math.PI ) + ", speed should be " + "" );
      // writeComment("y: " + y);
      writeBlock(gMotionModal.format(isSpeedFeedSynchronizationActive() ? 32 : 1), x, y, z, f);
    }
  } else if (f) {
    if (getNextRecord().isMotion()) { // try not to output feed without motion
      forceFeed(); // force feed on next line
    } else {
      writeBlock(gMotionModal.format(isSpeedFeedSynchronizationActive() ? 32 : 1), f);
    }
  }
}

function onCircular(clockwise, cx, cy, cz, x, y, z, feed) {
  if (isSpeedFeedSynchronizationActive()) {
    error(localize("Speed-feed synchronization is not supported for circular moves."));
    return;
  }

  if (pendingRadiusCompensation >= 0) {
    error(localize("Radius compensation cannot be activated/deactivated for a circular move."));
    return;
  }

  var start = getCurrentPosition();
  var directionCode = (toolingData.toolPost == REAR) ? (clockwise ? 2 : 3) : (clockwise ? 3 : 2);
  // writeComment("current x " + start.x + ", current y " + start.y + ", current z " + start.z);
  // writeComment("cx " + cx + " cy " + cy + " cz " + cz + " x " + x + " y " + y + " z " + z);

  if (isFullCircle()) {
    if (getProperty("useRadius") || isHelical()) { // radius mode does not support full arcs
      linearize(tolerance);
      return;
    }
    switch (getCircularPlane()) {
    case PLANE_XY:
      writeBlock((gAbsIncModal.format(90)), gPlaneModal.format(17), gMotionModal.format(directionCode), iOutput.format(cx - start.x, 0), jOutput.format(cy - start.y, 0), getFeed(feed));
      break;
    case PLANE_ZX:
      writeBlock((gAbsIncModal.format(90)), gPlaneModal.format(18), gMotionModal.format(directionCode), iOutput.format(cx - start.x, 0), kOutput.format(cz - start.z, 0), getFeed(feed));
      break;
    case PLANE_YZ:
      writeBlock((gAbsIncModal.format(90)), gPlaneModal.format(19), gMotionModal.format(directionCode), jOutput.format(cy - start.y, 0), kOutput.format(cz - start.z, 0), getFeed(feed));
      break;
    default:
      linearize(tolerance);
    }
  } else if (!getProperty("useRadius")) {
    switch (getCircularPlane()) {
    case PLANE_XY:
      writeBlock((gAbsIncModal.format(90)), gPlaneModal.format(17), gMotionModal.format(directionCode), xOutput.format(x), yOutput.format(y), zOutput.format(z), iOutput.format(cx - start.x, 0), jOutput.format(cy - start.y, 0), getFeed(feed));
      break;
    case PLANE_ZX:
      var arcRad = Math.sqrt(Math.pow(Math.abs(x-cx),2)+Math.pow(Math.abs(z-cz),2));
      var sectMidpoint = { x : (x + start.x ) / 2 , z : ( z + start.z ) / 2 };
      var arcAngle = Math.atan2(sectMidpoint.z-cz, sectMidpoint.x-cx);
      var arcMidpoint = { x : ( Math.cos( arcAngle ) * arcRad ) + cx, z : ( Math.sin( arcAngle ) * arcRad ) + cz };
      // writeComment("rad1 " + arcRad + ", sectMidpoint " + sectMidpoint.x + ", " + sectMidpoint.z + ", arcAngle " + arcAngle);
      // writeComment("arcMidpoint " + arcMidpoint.x + ",  " + arcMidpoint.z);
      // writeComment("x start " + start.x + ", x " + x + ", cx " + cx + ", z start " + start.z + ", z " + z + ", cz " + cz);
      writeBlock((gAbsIncModal.format(90)), gMotionModal.format(3.4), getMoveX(arcMidpoint.x), getMoveY(arcMidpoint.x), getMoveZ(arcMidpoint.z));
      writeBlock(getMoveX(x), getMoveY(x), getMoveZ(z));
      // writeBlock((gAbsIncModal.format(90)), gPlaneModal.format(19), gMotionModal.format(directionCode), xOutput.format(x), yOutput.format(y), zOutput.format(z), iOutput.format(cx - start.x, 0), kOutput.format(cz - start.z, 0), getFeed(feed));
      break;
    case PLANE_YZ:
      writeBlock((gAbsIncModal.format(90)), gPlaneModal.format(19), gMotionModal.format(directionCode), xOutput.format(x), yOutput.format(y), zOutput.format(z), jOutput.format(cy - start.y, 0), kOutput.format(cz - start.z, 0), getFeed(feed));
      break;
    default:
      linearize(tolerance);
    }
  } else { // use radius mode
    var r = getCircularRadius();
    if (toDeg(getCircularSweep()) > (180 + 1e-9)) {
      r = -r; // allow up to <360 deg arcs
    }
    switch (getCircularPlane()) {
    case PLANE_XY:
      writeBlock((gAbsIncModal.format(90)), gPlaneModal.format(17), gMotionModal.format(directionCode), xOutput.format(x), yOutput.format(y), zOutput.format(z), "R" + rFormat.format(r), getFeed(feed));
      break;
    case PLANE_ZX:
      writeBlock((gAbsIncModal.format(90)), gPlaneModal.format(18), gMotionModal.format(directionCode), xOutput.format(x), yOutput.format(y), zOutput.format(z), "R" + rFormat.format(r), getFeed(feed));
      break;
    case PLANE_YZ:
      writeBlock((gAbsIncModal.format(90)), gPlaneModal.format(19), gMotionModal.format(directionCode), xOutput.format(x), yOutput.format(y), zOutput.format(z), "R" + rFormat.format(r), getFeed(feed));
      break;
    default:
      linearize(tolerance);
    }
  }
}

function onCycle() {
}

var saveShowSequenceNumbers;
var pathBlockNumber = {start:0, end:0};

function onCyclePath() {
  if (!getProperty("isnc")) {
    error(localize("BNC mode does not support turning canned cycles."));
  }

  saveShowSequenceNumbers = getProperty("showSequenceNumbers");

  // buffer all paths and stop feeds being output
  feedOutput.disable();
  setProperty("showSequenceNumbers", "false");
  redirectToBuffer();
  gMotionModal.reset();
  if ((hasParameter("operation:grooving") && getParameter("operation:grooving").toUpperCase() != "OFF")) {
    forceXYZ();
  }
}

function onCyclePathEnd() {
  setProperty("showSequenceNumbers", saveShowSequenceNumbers); // reset property to initial state
  feedOutput.enable();
  var cyclePath = String(getRedirectionBuffer()).split(EOL); // get cycle path from buffer
  closeRedirection();
  for (var line in cyclePath) { // remove empty elements
    if (cyclePath[line] == "") {
      cyclePath.splice(line);
    }
  }

  var verticalPasses;
  if (cycle.profileRoughingCycle == 0) {
    verticalPasses = false;
  } else if (cycle.profileRoughingCycle == 1) {
    verticalPasses = true;
  } else {
    error(localize("Unsupported passes type."));
    return;
  }
  // output cycle data
  switch (cycleType) {
  case "turning-canned-rough":
    writeBlock(gFormat.format(verticalPasses ? 72 : 71),
      "U" + spatialFormat.format(cycle.depthOfCut),
      "R" + spatialFormat.format(cycle.retractLength)
    );
    writeBlock(gFormat.format(verticalPasses ? 72 : 71),
      "P" + (getStartEndSequenceNumber(cyclePath, true)),
      "Q" + (getStartEndSequenceNumber(cyclePath, false)),
      "U" + xFormat.format(cycle.xStockToLeave),
      "W" + spatialFormat.format(cycle.zStockToLeave),
      getFeed(cycle.cutfeedrate)
    );
    break;
  default:
    error(localize("Unsupported turning canned cycle."));
  }

  for (var i = 0; i < cyclePath.length; ++i) {
    if (i == 0 || i == (cyclePath.length - 1)) { // write sequence number on first and last line of the cycle path
      setProperty("showSequenceNumbers", "true");
      if ((i == 0 && pathBlockNumber.start != sequenceNumber) || (i == (cyclePath.length - 1) && pathBlockNumber.end != sequenceNumber)) {
        error(localize("Mismatch of start/end block number in turning canned cycle."));
        return;
      }
    }
    writeBlock(cyclePath[i]); // output cycle path
    setProperty("showSequenceNumbers", saveShowSequenceNumbers); // reset property to initial state
  }
}

function getStartEndSequenceNumber(cyclePath, start) {
  if (start) {
    pathBlockNumber.start = sequenceNumber + conditional(saveShowSequenceNumbers == "true", getProperty("sequenceNumberIncrement"));
    return pathBlockNumber.start;
  } else {
    pathBlockNumber.end = sequenceNumber + getProperty("sequenceNumberIncrement") + conditional(saveShowSequenceNumbers == "true", (cyclePath.length - 1) * getProperty("sequenceNumberIncrement"));
    return pathBlockNumber.end;
  }
}

function getCommonCycle(x, y, z, r) {
  forceXYZ(); // force xyz for turning
  return [xOutput.format(x), yOutput.format(y),
    zOutput.format(z),
    "R" + spatialFormat.format(r)];
}

function getThreadStockPoints(x, y, z) {
  // check for parameters
  if (!hasParameter("operation:threadDepth") ||
      !hasParameter("operation:stockOffsetBack") ||
      !hasParameter("operation:stockOffsetFront")) {
    error(localize("Mandatory cycle property not defined."));
    return undefined;
  }

  // calculate axial and radial offset directions
  var axialOffset = new Vector(-cycle.incrementalX, 0, -cycle.incrementalZ);
  var axialDirection = axialOffset.getNormalized();
  var radialDirection = new Vector(1, 0, 0);

  // get required parameters
  var threadHeight = getParameter("operation:threadDepth");
  var backOffset = getParameter("operation:stockOffsetBack") / axialDirection.z;
  var frontOffset = getParameter("operation:stockOffsetFront") / axialDirection.z;
  var lengthOfCut = (axialOffset.length - (backOffset + frontOffset));

  // final position at depth of threading moves
  var endPoint = new Vector(x, y, z);

  // calculate top of stock points
  var stockEnd = Vector.sum(endPoint, Vector.product(axialDirection, backOffset));
  var stockPoint = {};
  stockPoint.second = Vector.sum(stockEnd, Vector.product(radialDirection, threadHeight));
  stockPoint.first = Vector.sum(stockPoint.second, Vector.product(axialDirection, lengthOfCut));
  return stockPoint;
}

var threadNumber = 0;
var numberOfThreads = 1;
function onCyclePoint(x, y, z) {
  
  var millx = tool.offsetx+getProperty("blockCentreX");
  var milly = tool.offsety+getProperty("blockCentreY");
  var millz = tool.offsetz+z;
  // var f = getFeed( feed );
  if (isSameDirection(currentSection.workPlane.forward, new Vector(0, 0, 1)) ||
      isSameDirection(currentSection.workPlane.forward, new Vector(0, 0, -1))) {
    // check direction
  } else {
    expandCyclePoint(x, y, z);
    return;
  }

  switch (cycleType) {
  case "thread-turning":
    // find number of threads and count which thread we are on
    numberOfThreads = 1;
    if ((hasParameter("operation:doMultipleThreads") && (getParameter("operation:doMultipleThreads") != 0))) {
      numberOfThreads = getParameter("operation:numberOfThreads");
    }
    var inverted = (toolingData.toolPost == REAR) ? 1 : -1;
    if (isFirstCyclePoint()) {
      // increment thread number for multiple threads
      threadNumber += 1;
    }
    var threadPhaseAngle = (360 / numberOfThreads) * (threadNumber - 1);
    if (!getProperty("isnc")) {
      if (isLastCyclePoint() && (numberOfThreads == 1 || numberOfThreads == threadNumber)) {
        // thread height and depth of cut
        var threadHeight = getParameter("operation:threadDepth");
        var firstDepthOfCut = threadHeight - Math.abs(getCyclePoint(0).x - x);
        var repeatPass = getParameter("operation:nullPass", 0);
        var cuttingAngle = getParameter("operation:infeedAngle", 60); // Angle is not stored with tool. toDeg(tool.getTaperAngle());
        var threadInfeedMode = getParameter("operation:infeedMode", "constant");
        var id = hasParameter("operation:machineInside") && getParameter("operation:machineInside") == 1;

        // start and end of thread on physical part
        var stockPoints = getThreadStockPoints(x, y, z);

        var i = -cycle.incrementalX * inverted; // positive if taper goes down - delta radius

        gCycleModal.reset();
        writeBlock(
          gCycleModal.format(78),
          xOutput.format(x),
          zOutput.format(z),
          // for id threads J must have opposite sign of X.
          "J" + spatialFormat.format((id ? -1 : 1) * Math.abs(threadHeight)),
          "K" + spatialFormat.format(stockPoints.first.z),
          "U" + spatialFormat.format(cycle.clearance - stockPoints.first.x),
          "W" + spatialFormat.format(cycle.clearance - stockPoints.first.x), // same radial clerance will be used for the axial clerance as well
          conditional(i, "B" + spatialFormat.format(Math.atan2(cycle.incrementalX, cycle.incrementalZ))),
          "D" + spatialFormat.format(firstDepthOfCut),
          conditional(threadInfeedMode == "reduced", "V1"),
          // "A" + spatialFormat.format(cuttingAngle),
          conditional(repeatPass > 0, "R" + integerFormat.format(repeatPass)),
          conditional(numberOfThreads > 1, "Q" + integerFormat.format(numberOfThreads)),
          pitchOutput.format(cycle.pitch)
        );
        forceFeed();
        gMotionModal.reset();
      }
    } else {
      if (getProperty("useSimpleThread") || (hasParameter("operation:infeedMode") && (getParameter("operation:infeedMode") == "alternate"))) {
        var i = -cycle.incrementalX * inverted; // positive if taper goes down - delta radius
        // move to thread start for infeed angle other than 0, multiple threads and alternate infeed.
        if (zFormat.areDifferent(zOutput.getCurrent(), zFormat.getResultingValue(z))) {
          var _z = zOutput.format(z - cycle.incrementalZ);
          if (_z) {
            writeBlock(gMotionModal.format(0), _z);
          }
          forceThread();
        }

        writeBlock(
          gCycleModal.format(92),
          xOutput.format(x - cycle.incrementalX),
          yOutput.format(y),
          zOutput.format(z),
          conditional(zFormat.isSignificant(i), g92IOutput.format(i)),
          conditional(numberOfThreads > 1, g92QOutput.format(threadPhaseAngle)),
          feedOutput.format(cycle.pitch)
        );
      } else {
        if (isLastCyclePoint()) {
        // thread height and depth of cut
          var threadHeight = getParameter("operation:threadDepth");
          var firstDepthOfCut = threadHeight - Math.abs(getCyclePoint(0).x - x);
          var minimumDepthOfCut = Math.abs(getCurrentPosition().x - x);
          var cuttingAngle = getParameter("operation:infeedAngle", 30) * 2; // Angle is not stored with tool. toDeg(tool.getTaperAngle());

          // first G76 block
          var repeatPass = getParameter("operation:nullPass", 1) + 1; //First two digits of P value ranges from 1 to 99.
          var chamferWidth = 10; // Pullout-width is 1*thread-lead in 1/10's;
          var materialAllowance = 0; // Material allowance for finishing pass

          var pcode = repeatPass * 10000 + chamferWidth * 100 + cuttingAngle;
          gCycleModal.reset();
          writeBlock(
            gCycleModal.format(76),
            threadP1Output.format(pcode),
            threadQOutput.format(minimumDepthOfCut),
            threadROutput.format(materialAllowance)
          );
          // second G76 block
          var r = -cycle.incrementalX * inverted; // positive if taper goes down - delta radius
          gCycleModal.reset();
          writeBlock(
            gCycleModal.format(76),
            xOutput.format(x),
            zOutput.format(z),
            threadR2Output.format(r),
            threadP2Output.format(threadHeight),
            threadQOutput.format(firstDepthOfCut),
            pitchOutput.format(cycle.pitch)
          );
          forceFeed();
        }
      }
    }
    return;
  }

  if (!getProperty("useCycles")) {
    if (tapping) {
      error(localize("Tapping cycles cannot be expanded."));
      return;
    }
    expandCyclePoint(x, y, z);
    return;
  }

  if (isFirstCyclePoint()) {
    repositionToCycleClearance(cycle, x, y, z);

    var F = cycle.feedrate;
    var P = !cycle.dwell ? 0 : clamp(0.001, cycle.dwell, 99999.999); // in seconds
    if (!getProperty("isnc")) {
      P = (gFeedModeModal.getCurrent() == 95 ? P * (spindleSpeed / 60) : P);
    }
    switch (cycleType) {
    case "drilling":
      writeBlock(
        gCycleModal.format(81),
        getCommonCycle(x, y, z, cycle.retract),
        feedOutput.format(F)
      );
      break;
    case "counter-boring":
      if (P > 0) {
        writeBlock(
          gCycleModal.format(82),
          getCommonCycle(x, y, z, cycle.retract),
          conditional(P > 0, "P" + secFormat.format(P)),
          feedOutput.format(F)
        );
      } else {
        writeBlock(
          gCycleModal.format(81),
          getCommonCycle(x, y, z, cycle.retract),
          feedOutput.format(F)
        );
      }
      break;
    case "chip-breaking":
      if ((cycle.accumulatedDepth < cycle.depth) || (P > 0 && !getProperty("isnc"))) {
        expandCyclePoint(x, y, z);
      } else {
        writeBlock(
          gCycleModal.format(getProperty("isnc") ? 83.1 : 73),
          getCommonCycle(x, y, z, cycle.retract),
          conditional(P > 0, "P" + secFormat.format(P)),
          peckOutput.format(cycle.incrementalDepth),
          feedOutput.format(F)
        );
      }
      break;
    case "deep-drilling":
      if (P > 0 && !getProperty("isnc")) {
        expandCyclePoint(millx, milly, millz);
      } else {
        writeBlock(
          gCycleModal.format(83),
          getCommonCycle(millx, milly, millz, ( tool.offsetz+cycle.retract ) ),
          // getCommonCycle(x, y, z, cycle.retract));
          // writeComment(tool.offsetx+getProperty("blockCentreX"));
          // writeComment(millx+", "+ milly +", "+millz +", " + cycle.retract);
          // writeBlock(
          peckOutput.format(cycle.incrementalDepth),
          conditional(P > 0, "P" + secFormat.format(P)),
          feedOutput.format(F)
        );
      }
      break;
    case "tapping":
    case "left-tapping":
    case "right-tapping":
      F = tool.getThreadPitch() * rpmFormat.getResultingValue(spindleSpeed);
      if (getProperty("isnc")) {
        writeBlock(
          gCycleModal.format((getProperty("useRigidTapping") ? 84.2 : 84) + (tool.type == TOOL_TAP_LEFT_HAND ? 0.1 : 0)),
          getCommonCycle(x, y, z, cycle.retract),
          conditional(P > 0, "P" + secFormat.format(P)),
          pitchOutput.format(F)
        );
      } else {
        if (getProperty("useRigidTapping")) {
          writeBlock(mFormat.format(74));
        }
        writeBlock(
          gCycleModal.format(tool.type == TOOL_TAP_LEFT_HAND ? 84 : 74),
          getCommonCycle(x, y, z, cycle.retract),
          conditional(P > 0, "P" + secFormat.format(P)),
          pitchOutput.format(F)
        );
      }
      break;
    case "tapping-with-chip-breaking":
      if (!getProperty("isnc")) {
        error(localize("Tapping cycles cannot be expanded."));
        return;
      } else {
        F = tool.getThreadPitch() * rpmFormat.getResultingValue(spindleSpeed);
        writeBlock(
          gCycleModal.format((getProperty("useRigidTapping") ? 84.2 : 84) + (tool.type == TOOL_TAP_LEFT_HAND ? 0.1 : 0)),
          getCommonCycle(x, y, z, cycle.retract),
          conditional(P > 0, "P" + secFormat.format(P)),
          peckOutput.format(cycle.incrementalDepth),
          pitchOutput.format(F)
        );
      }
      break;
    case "reaming":
      if (feedFormat.getResultingValue(cycle.feedrate) != feedFormat.getResultingValue(cycle.retractFeedrate)) {
        expandCyclePoint(x, y, z);
        break;
      }
      if (!getProperty("isnc")) {
        expandCyclePoint(x, y, z);
      } else {
        writeBlock(
          gCycleModal.format(85),
          getCommonCycle(x, y, z, cycle.retract),
          conditional(P > 0, "P" + secFormat.format(P)),
          feedOutput.format(F)
        );
      }
      break;
    case "stop-boring":
      if (!getProperty("isnc")) {
        expandCyclePoint(x, y, z);
      } else {
        writeBlock(
          gCycleModal.format(86),
          getCommonCycle(x, y, z, cycle.retract),
          conditional(P > 0, "P" + secFormat.format(P)),
          feedOutput.format(F)
        );
      }
      break;
    case "boring":
      if (feedFormat.getResultingValue(cycle.feedrate) != feedFormat.getResultingValue(cycle.retractFeedrate)) {
        expandCyclePoint(x, y, z);
        break;
      }
      if (!getProperty("isnc")) {
        expandCyclePoint(x, y, z);
      } else {
        writeBlock(
          gCycleModal.format(85),
          getCommonCycle(x, y, z, cycle.retract),
          conditional(P > 0, "P" + secFormat.format(P)),
          feedOutput.format(F)
        );
      }
      break;
    default:
      if (tapping) {
        error(localize("Tapping cycles cannot be expanded."));
        return;
      }
      expandCyclePoint(x, y, z);
    }
  } else {
    if (cycleExpanded) {
      if (tapping) {
        error(localize("Tapping cycles cannot be expanded."));
        return;
      }
      expandCyclePoint(x, y, z);
    } else {
      var _x = xOutput.format(x);
      var _y = yOutput.format(y);
      var _z = zOutput.format(z);
      if (!_x && !_y && !_z) {
        switch (gPlaneModal.getCurrent()) {
        case 17: // XY
          xOutput.reset(); // at least one axis is required
          _x = xOutput.format(x);
          break;
        case 18: // ZX
          zOutput.reset(); // at least one axis is required
          _z = zOutput.format(z);
          break;
        case 19: // YZ
          yOutput.reset(); // at least one axis is required
          _y = yOutput.format(y);
          break;
        }
      }
      writeBlock(_x, _y, _z);
    }
  }
}

function onCycleEnd() {
  if (!cycleExpanded) {
    switch (cycleType) {
    case "thread-turning":
      forceThread();
      if (threadNumber == numberOfThreads) {
        threadNumber = 0;
        writeBlock(gCycleModal.format(80));
      }
      gMotionModal.reset();
      break;
    default:
      writeBlock(gCycleModal.format(80));
      gMotionModal.reset();
    }
  }
}

var currentCoolantMode = COOLANT_OFF;
var coolantOff = undefined;
var forceCoolant = false;

function setCoolant(coolant) {
  // cancel coolant if necessary
  if ((coolant != COOLANT_OFF) && (currentCoolantMode != COOLANT_OFF) && (coolant != currentCoolantMode) && !forceCoolant) {
    setCoolant(COOLANT_OFF);
  }
  var coolantCodes = getCoolantCodes(coolant);
  if (Array.isArray(coolantCodes)) {
    if (singleLineCoolant) {
      writeBlock(coolantCodes.join(getWordSeparator()));
    } else {
      for (var c in coolantCodes) {
        writeBlock(coolantCodes[c]);
      }
    }
    return undefined;
  }
  return coolantCodes;
}

function getCoolantCodes(coolant) {
  if ((getProperty("useCoolant") != undefined) && !getProperty("useCoolant")) {
    return undefined;
  }
  if (!coolants) {
    error(localize("Coolants have not been defined."));
  }
  if (isProbeOperation()) { // avoid coolant output for probing
    coolant = COOLANT_OFF;
  }
  if (coolant == currentCoolantMode && (!forceCoolant || coolant == COOLANT_OFF)) {
    return undefined; // coolant is already active
  }

  forceCoolant = false;

  var multipleCoolantBlocks = new Array(); // create a formatted array to be passed into the output line
  var m;
  var coolantCodes = {};
  for (var c in coolants) { // find required coolant codes into the coolants array
    if (coolants[c].id == coolant) {
      coolantCodes.on = coolants[c].on;
      if (coolants[c].off != undefined) {
        coolantCodes.off = coolants[c].off;
        break;
      } else {
        for (var i in coolants) {
          if (coolants[i].id == COOLANT_OFF) {
            coolantCodes.off = coolants[i].off;
            break;
          }
        }
      }
    }
  }
  if (coolant == COOLANT_OFF) {
    m = !coolantOff ? coolantCodes.off : coolantOff; // use the default coolant off command when an 'off' value is not specified
  } else {
    coolantOff = coolantCodes.off;
    m = coolantCodes.on;
  }

  if (!m) {
    onUnsupportedCoolant(coolant);
    m = 9;
  } else {
    if (Array.isArray(m)) {
      for (var i in m) {
        multipleCoolantBlocks.push(mFormat.format(m[i]));
      }
    } else {
      multipleCoolantBlocks.push(mFormat.format(m));
    }
    currentCoolantMode = coolant;
    return multipleCoolantBlocks; // return the single formatted coolant value
  }
  return undefined;
}

function onSpindleSpeed(spindleSpeed) {
  if (rpmFormat.areDifferent(spindleSpeed, sOutput.getCurrent())) {
    writeBlock(sOutput.format(spindleSpeed));
  }
}

function startSpindle(tappingMode, forceRPMMode, initialPosition) {
  var spindleDir;
  var _spindleSpeed;
  var spindleMode;
  var maxSpeed = "";
  gSpindleModeModal.reset();
  gSpindleModeModal.reset();

  if ((getSpindle() == SPINDLE_SECONDARY) && !gotSecondarySpindle) {
    error(localize("Secondary spindle is not available."));
    return;
  }

  if (getSpindle() == SPINDLE_SECONDARY) {
    spindleDir = tool.clockwise ? getCode("START_SUB_SPINDLE_CW") : getCode("START_SUB_SPINDLE_CCW");
  } else {
    spindleDir = tool.clockwise ? getCode("START_MAIN_SPINDLE_CW") : getCode("START_MAIN_SPINDLE_CCW");
  }

  var maximumSpindleSpeed = (tool.maximumSpindleSpeed > 0) ? Math.min(tool.maximumSpindleSpeed, getProperty("maximumSpindleSpeed")) : getProperty("maximumSpindleSpeed");
  if (tool.getSpindleMode() == SPINDLE_CONSTANT_SURFACE_SPEED) {
    _spindleSpeed = tool.surfaceSpeed * ((unit == MM) ? 1 / 1000.0 : 1 / 12.0);
    if (forceRPMMode) { // RPM mode is forced until move to initial position
      if (xFormat.getResultingValue(initialPosition.x) == 0) {
        _spindleSpeed = maximumSpindleSpeed;
      } else {
        _spindleSpeed = Math.min((_spindleSpeed * ((unit == MM) ? 1000.0 : 12.0) / (Math.PI * Math.abs(initialPosition.x * 2))), maximumSpindleSpeed);
      }
      spindleMode = getCode("CONSTANT_SURFACE_SPEED_OFF");
    } else {
      // writeBlock(gFormat.format(92), sOutput.format(maximumSpindleSpeed));
      spindleMode = getCode("CONSTANT_SURFACE_SPEED_ON");
    }
  } else {
    _spindleSpeed = spindleSpeed;
    spindleMode = getCode("CONSTANT_SURFACE_SPEED_OFF");
  }
  if (getSpindle(true) == SPINDLE_SECONDARY) {
    writeBlock(
      spindleMode,
      sOutput.format(_spindleSpeed),
      spindleDir
    );
  } else {
    // writeComment("here");
    writeBlock(
      spindleMode,
      sOutput.format(_spindleSpeed),
      spindleDir
    );
  }
  // wait for spindle here if required
}

function onCommand(command) {
  switch (command) {
  case COMMAND_COOLANT_OFF:
    setCoolant(COOLANT_OFF);
    break;
  case COMMAND_COOLANT_ON:
    setCoolant(COOLANT_FLOOD);
    break;
  case COMMAND_LOCK_MULTI_AXIS:
    break;
  case COMMAND_UNLOCK_MULTI_AXIS:
    break;
  case COMMAND_START_CHIP_TRANSPORT:
    getCode("START_CHIP_TRANSPORT");
    break;
  case COMMAND_STOP_CHIP_TRANSPORT:
    getCode("STOP_CHIP_TRANSPORT");
    break;
  case COMMAND_BREAK_CONTROL:
    break;
  case COMMAND_TOOL_MEASURE:
    break;
  case COMMAND_ACTIVATE_SPEED_FEED_SYNCHRONIZATION:
    break;
  case COMMAND_DEACTIVATE_SPEED_FEED_SYNCHRONIZATION:
    break;
  case COMMAND_STOP:
    writeBlock(mFormat.format(0));
    forceSpindleSpeed = true;
    forceCoolant = true;
    break;
  case COMMAND_OPTIONAL_STOP:
    writeBlock(mFormat.format(1));
    forceSpindleSpeed = true;
    forceCoolant = true;
    break;
  case COMMAND_END:
    writeBlock(mFormat.format(2));
    break;
  case COMMAND_SPINDLE_CLOCKWISE:
    switch (currentSection.spindle) {
    case SPINDLE_PRIMARY:
      writeBlock(mFormat.format(3));
      break;
    case SPINDLE_SECONDARY:
      writeBlock(mFormat.format(143));
      break;
    }
    break;
  case COMMAND_SPINDLE_COUNTERCLOCKWISE:
    switch (currentSection.spindle) {
    case SPINDLE_PRIMARY:
      writeBlock(mFormat.format(4));
      break;
    case SPINDLE_SECONDARY:
      writeBlock(mFormat.format(144));
      break;
    }
    break;
  case COMMAND_START_SPINDLE:
    onCommand(tool.clockwise ? COMMAND_SPINDLE_CLOCKWISE : COMMAND_SPINDLE_COUNTERCLOCKWISE);
    break;
  case COMMAND_STOP_SPINDLE:
    switch (currentSection.spindle) {
    case SPINDLE_PRIMARY:
      writeBlock(mFormat.format(5));
      break;
    case SPINDLE_SECONDARY:
      writeBlock(mFormat.format(145));
      break;
    }
    break;
  case COMMAND_ORIENTATE_SPINDLE:
    if (getSpindle() == 0) {
      writeBlock(mFormat.format(19)); // use P or R to set angle (optional)
    } else {
      writeBlock(mFormat.format(119));
    }
    break;
  //case COMMAND_CLAMP: // TAG: add support for clamping
  //case COMMAND_UNCLAMP: // TAG: add support for clamping
  default:
    onUnsupportedCommand(command);
  }
}

function engagePartCatcher(engage) {
  if (engage) {
    // catch part here
    writeBlock(getCode("PART_CATCHER_ON"), formatComment(localize("PART CATCHER ON")));
  } else {
    onCommand(COMMAND_COOLANT_OFF);
    writeRetract();
    writeBlock(getCode("PART_CATCHER_OFF"), formatComment(localize("PART CATCHER OFF")));
    forceXYZ();
  }
}

function onSectionEnd() {

  // cancel SFM mode to preserve spindle speed
  if (tool.getSpindleMode() == SPINDLE_CONSTANT_SURFACE_SPEED) {
    // startSpindle(false, true, getFramePosition(currentSection.getFinalPosition()));
  }

  if (currentSection.partCatcher) {
    engagePartCatcher(false);
  }

  forceAny();
}

/** Output block to do safe retract and/or move to home position. */
var XZ = 4;
function writeRetract() {
  var words = []; // store all retracted axes in an array
  var singleLineRetract = false;
  var retractAxes = []; // axes to retract

  var method = !getProperty("isnc") ? "G53" : getProperty("safePositionMethod");
  // define home positions
  var _xHome;
  var _yHome;
  var _zHome;
  if (method == "G28") {
    _xHome = toPreciseUnit(0, MM);
    _yHome = toPreciseUnit(0, MM);
    _zHome = toPreciseUnit(0, MM);
  } else {
    _xHome = machineConfiguration.hasHomePositionX() ? machineConfiguration.getHomePositionX() : getProperty("homePositionX");
    _yHome = machineConfiguration.hasHomePositionY() ? machineConfiguration.getHomePositionY() : toPreciseUnit(0, MM);
    _zHome = machineConfiguration.getRetractPlane() != 0 ? machineConfiguration.getRetractPlane() : getProperty("homePositionZ");
  }

  if (arguments.length > 0) {
    for (var i in arguments) {
      retractAxes.push(arguments[i]);
      singleLineRetract = arguments[i] == XZ ? true : singleLineRetract;
    }
  } else {
    switch (getProperty("safePositionStyle")) {
    case "X":
      retractAxes.push(X);
      break;
    case "Z":
      retractAxes.push(Z);
      break;
    case "XZ":
      retractAxes.push(X, Z);
      break;
    case "ZX":
      retractAxes.push(Z, X);
      break;
    case "singleLineXZ":
      singleLineRetract = true;
      retractAxes.push(X, Z);
      break;
    }
  }

  // format home positions
  for (var i = 0; i < retractAxes.length; ++i) {
    switch (retractAxes[i]) {
    case X:
      words.push((method == "G28" ? "U" : "X") + xFormat.format(_xHome));
      retracted[X] = true;
      xOutput.reset();
      break;
    case Y:
      if (yOutput.isEnabled()) {
        words.push((method == "G28" ? "V" : "Y") + yFormat.format(_yHome));
        yOutput.reset();
      }
      break;
    case Z:
      words.push((method == "G28" ? "W" : "Z") + zFormat.format(_zHome));
      retracted[Z] = true;
      zOutput.reset();
      break;
    case XZ:
      words.push((method == "G28" ? "U" : "X") + xFormat.format(_xHome));
      words.push((method == "G28" ? "W" : "Z") + zFormat.format(_zHome));
      retracted[X] = true;
      retracted[Z] = true;
      xOutput.reset();
      zOutput.reset();
      break;
    default:
      error(localize("Unsupported axis specified for writeRetract()."));
      return;
    }
  }
  for (var i = 0; i < words.length; ++i) {
    switch (method) {
    case "G28":
      gAbsIncModal.reset();
      writeBlock(gFormat.format(28), singleLineRetract ? words : words[i]);
      break;
    case "G53":
      gMotionModal.reset();
      writeBlock(gFormat.format(53), gMotionModal.format(0), singleLineRetract ? words : words[i]);
      break;
    default:
      error(localize("Unsupported safe position method."));
      return;
    }
    if (singleLineRetract) {
      break;
    }
  }
  singleLineRetract = false; // singleLineRetract reset
}

function onClose() {
  writeln("");

  optionalSection = false;

  onCommand(COMMAND_COOLANT_OFF);

  //Turn off chip conveyor
  writeBlock(mFormat.format(61));
  //Move bed to front
  writeBlock("G53 G0 Z0.");
  writeBlock("G53 G0 X300. Y400.");

  //Coordinate system rotation cancel
  writeBlock(gFormat.format(69));

  forceXYZ();
  // writeRetract(); // change this to writeRetract(XZ) to force retract in XZ at the end of the program as a default

  onImpliedCommand(COMMAND_END);
  onImpliedCommand(COMMAND_STOP_SPINDLE);
  writeBlock(mFormat.format(2)); // stop program, spindle stop, coolant off
  writeln("%");
}

function setProperty(property, value) {
  properties[property].current = value;
}
