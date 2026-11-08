/**
  Copyright (C) 2012-2020 by Autodesk, Inc.
  All rights reserved.

  HURCO post processor configuration.

  $Revision: 42984 befa955a1a91b49c9aff39d6ee00f888b2961ff1 $
  $Date: 2020-11-09 12:34:19 $
  
  FORKID {1B14E478-26FE-4db2-A3E7-FB814E8C0B4E}
*/

description = "HURCO";
vendor = "HURCO";
vendorUrl = "http://www.hurco.com";
legal = "Copyright (C) 2012-2020 by Autodesk, Inc.";
certificationLevel = 2;
minimumRevision = 40783;

longDescription = "Generic post for HURCO. Note that this post supports both ISNC (ISO NC mode) and BNC (Basic NC mode). By default ISNC mode is used but you can switch to BNC mode by disabling the 'isnc' property. Also note that you can turn on 3D arcs by enabling the 'allow3DArcs' property so you will get arcs in any plane instead of only in the primary planes G17/G18/G19. Note that the HURCO CNC cannot guarantee that no gouging will happen at rewinds when using vector output for multi-axis simultaneous machining as vector does not provide enough information. You need to define the machine in the post to be safe. V4 - added zero RPM to tool if it has comment 'broach'";

extension = "hnc";
programNameIsInteger = true;
setCodePage("ascii");

capabilities = CAPABILITY_MILLING | CAPABILITY_MACHINE_SIMULATION;
tolerance = spatial(0.002, MM);

minimumChordLength = spatial(0.025, MM);
minimumCircularRadius = spatial(0.01, MM);
maximumCircularRadius = spatial(1000, MM);
minimumCircularSweep = toRad(0.01);
maximumCircularSweep = toRad(180);
allowHelicalMoves = true;
allowedCircularPlanes = undefined; // allow any circular motion
highFeedrate = (unit == IN) ? 100 : 5000;

// user-defined properties
properties = {
  writeMachine: {title:"Write machine", description:"Output the machine settings in the header of the code.", group:"formats", type:"boolean", value:true, scope:"post"},
  writeTools: {title:"Write tool list", description:"Output a tool list in the header of the code.", group:"formats", type:"boolean", value:true, scope:"post"},
  preloadTool: {title:"Preload tool", description:"Preloads the next tool at a tool change (if any).", group:"preferences", type:"boolean", value:true, scope:"post"},
  showSequenceNumbers: {title:"Use sequence numbers", description:"Use sequence numbers for each block of outputted code.", group:"formats", type:"boolean", value:true, scope:"post"},
  sequenceNumberStart: {title:"Start sequence number", description:"The number at which to start the sequence numbers.", group:"formats", type:"integer", value:1, scope:"post"},
  sequenceNumberIncrement: {title:"Sequence number increment", description:"The amount by which the sequence number is incremented by in each block.", group:"formats", type:"integer", value:1, scope:"post"},
  broachReversal: {title:"Broaching tool reversal distance", description:"This is the distance after which the spindle reverses when using a broach tool, to get a straight hole. Zero denotes no reversing.", group:"preferences", type:"integer", range:[0, 9999], value:1, scope:"post"},
  optionalStop: {title:"Optional stop", description:"Outputs optional stop code during when necessary in the code.", group:"preferences", type:"boolean", value:true, scope:"post"},
  isnc: {title:"Use ISNC or BNC mode", description:"Selects between ISNC (ISO NC mode) and BNC (Basic NC mode).", group:"configuration", type:"boolean", values:["Basic NC mode", "ISO NC mode"], value:true, scope:"post"},
  separateWordsWithSpace: {title:"Separate words with space", description:"Adds spaces between words if 'yes' is selected.", group:"formats", type:"boolean", value:true, scope:"post"},
  allow3DArcs: {title:"Allow 3D arcs", description:"Specifies whether 3D circular arcs are allowed.", group:"preferences", type:"boolean", value:false, scope:"post"},
  useParametricFeed: {title:"Parametric feed", description:"Specifies the feed value that should be output using a Q value.", group:"preferences", type:"boolean", value:false, scope:"post"},
  showNotes: {title:"Show notes", description:"Writes operation notes as comments in the outputted code.", group:"formats", type:"boolean", value:false, scope:"post"},
  preferPositiveTilt: {title:"Prefer positive tilt", description:"Specifies whether to prefer positive or negative tilt angles.", group:"multiAxis", type:"boolean", value:false, scope:"post"},
  safeToolChangePositionX: {title:"Safe tool change position X", description:"Specify whether to use a safe tool change position in the X axis.", group:"homePositions", type:"boolean", value:false, scope:"post"},
  safeToolChangePositionY: {title:"Safe tool change position Y", description:"Specify whether to use a safe tool change position in the Y axis.", group:"homePositions", type:"boolean", value:false, scope:"post"},
  machineAxisABC: {title:"Machine axes", description:"Specify your machine axes here, for use with vector output only.", group:"multiAxis", type:"string", value:"ABC", scope:"post"},
  safePositionMethod: {
    title      : "Safe Retracts",
    description: "Select your desired retract option. 'Clearance Height' retracts to the operation clearance height.",
    group      : "homePositions",
    type       : "enum",
    values     : [
      // {title:"G28", id:"G28"},
      {title:"G53", id:"G53"},
      {title:"Clearance Height", id:"clearanceHeight"}
    ],
    value: "G53",
    scope: "post"
  }
};

// >>>>> INCLUDED FROM edgeFeed.cpi
/**
  Edge feed module for Autodesk Fusion post processors.

  Fusion programs a constant feed at the tool centre. On a curve, the cutting edge touching the
  wall travels on a different radius, so the feed at the edge is higher than programmed in inside
  corners and lower around outside profiles. This module rescales the centre-line feed so that
  the edge in contact with the wall moves at the programmed feed.

  - Arcs (onCircular) are corrected from the arc radius.
  - Linear moves are buffered by one move so that the curvature at each segment can be fitted
    from the neighbouring points. Only chains of segments that are consistent with a curve
    linearised at the operation tolerance are corrected; true straight lines are never changed.

  Curvature is measured in the XY plane, so the module is intended for 3-axis machines with the
  tool along Z. 3D toolpaths are allowed but experimental.

  Porting into a post (see README.md for details):
    1. Paste this file (or use tools/inline.sh) anywhere at top level in the post.
    2. Merge the properties:   edgeFeedMergeProperties(properties);   (top level, after 'properties')
    3. onOpen():               edgeFeed.init({writeLinear:writeLinear, writeArcXY:writeArcXY, writeComment:writeComment});
                               writeLinear(x, y, z, feed) and writeArcXY(clockwise, cx, cy, x, y, z, feed, start) write one move
                               without using getCurrentPosition() or other current-record functions (they are called late).
                               writeArcXY is optional; without it corner rolls are not grouped into faceted curves.
    4. onSection():            edgeFeed.onSection(currentSection, tool);
    5. onLinear():             if (pendingRadiusCompensation < 0 && edgeFeed.onLinear(_x, _y, _z, feed)) {return;}
                               edgeFeed.flush();  // then the post's normal linear output, moved into writeLinear()
    6. onCircular():           if (edgeFeed.onCircular(clockwise, cx, cy, cz, x, y, z, feed)) {return;}
                               feed = edgeFeed.circularFeed(clockwise, cx, cy, cz, x, y, z, feed);
    7. Every other entry point that writes output (onRapid, onRapid5D, onLinear5D, onCycle, onCyclePoint,
       onCommand, onDwell, onPassThrough, onRadiusCompensation, onSectionEnd, ...): edgeFeed.flush();
    8. onSectionEnd():         edgeFeed.onSectionEnd();
*/

var EDGE_FEED_VERSION = "0.2.1";

var edgeFeedProperties = {
  edgeFeedEnable: {
    title      : "Edge feed: enable",
    description: "Adjust the centre-line feed so the cutting edge in contact with the wall moves at the programmed feed. Set per operation in the Post Process tab.",
    group      : "preferences",
    type       : "boolean",
    value      : false,
    scope      : "operation"
  },
  edgeFeedMaxFactor: {
    title      : "Edge feed: max speed-up factor",
    description: "Maximum multiplier applied to the programmed feed on outside curves. The post value is the default, and an operation can override it.",
    group      : "preferences",
    type       : "number",
    value      : 2,
    scope      : ["post", "operation"]
  },
  edgeFeedMinFactor: {
    title      : "Edge feed: min slow-down factor",
    description: "Minimum multiplier applied to the programmed feed in inside corners.",
    group      : "preferences",
    type       : "number",
    value      : 0.1,
    scope      : "post"
  },
  edgeFeedMaxFeed: {
    title      : "Edge feed: max cutting feed",
    description: "The adjusted feed is never raised above this value (0 = no limit). Programmed feeds above it are left as they are.",
    group      : "preferences",
    type       : "number",
    value      : 0,
    scope      : "post"
  },
  edgeFeedSagittaMargin: {
    title      : "Edge feed: tolerance margin",
    description: "Linear segments are treated as part of a curve when their deviation from the fitted circle is within the operation tolerance times (1 + margin).",
    group      : "preferences",
    type       : "number",
    value      : 0.5,
    scope      : "post"
  },
  edgeFeedVertexSweep: {
    title      : "Edge feed: facet vertex sweep (deg)",
    description: "Fusion rolls the tool around each sharp outside corner with an arc of the tool radius. Corner rolls up to this sweep are treated as vertices of a faceted curve, and get the feed of a circle fitted through the vertices. Larger corner rolls are real corners and get the max speed-up factor.",
    group      : "preferences",
    type       : "number",
    value      : 15,
    scope      : "post"
  },
  edgeFeedDebug: {
    title      : "Edge feed: debug comments",
    description: "Write a comment with the fitted radius and feed factor before each adjusted move.",
    group      : "preferences",
    type       : "boolean",
    value      : false,
    scope      : "post"
  }
};

/** Adds the edge feed properties to the post's properties object. */
function edgeFeedMergeProperties(target) {
  for (var name in edgeFeedProperties) {
    if (target[name] === undefined) {
      target[name] = edgeFeedProperties[name];
    }
  }
}

var edgeFeed = {
  // fixed settings, can be changed by the host post
  settings: {
    minTurnAngle  : 0.05 * Math.PI / 180, // turns below this angle are straight lines
    radiusRatio   : 1.25, // the two fitted circles around a segment must agree within this ratio
    minXYFraction : 0.5, // segments with less XY travel than this fraction of their length are not adjusted
    epsilon       : 1e-6,
    movements     : undefined // movement types that are adjusted, set in init()
  },

  host : undefined, // {writeLinear:function(x, y, z, feed), writeComment:function(text)}
  state: undefined, // per section configuration and statistics
  buffer: undefined, // linear move look-ahead

  /* ---------------------------------------------------------------------------------------------
     Pure geometry, no dependency on the post kernel (unit tested in test/)
  --------------------------------------------------------------------------------------------- */

  /**
    Returns the centre-line feed multiplier for a curve.
    @param postedRadius   radius of the posted path (the tool centre, or the part profile if compensation is in the control)
    @param toolRadius     tool radius
    @param turn           +1 curve turns left (CCW), -1 turns right (CW)
    @param side           +1 wall on the left of the direction of travel, -1 on the right
    @param profilePosted  true when the posted path is the part profile (compensation in the control)
    @return {factor, centreRadius, wallRadius}, factor is unclamped (Infinity when the wall radius is ~0)
  */
  curveFactor: function (postedRadius, toolRadius, turn, side, profilePosted) {
    var wallInside = (turn == side); // the wall is on the inside of the curve (outside corner)
    var rc, rw;
    if (profilePosted) {
      rw = postedRadius;
      rc = wallInside ? rw + toolRadius : rw - toolRadius;
    } else {
      rc = postedRadius;
      rw = wallInside ? rc - toolRadius : rc + toolRadius;
    }
    var factor;
    if (rc <= edgeFeed.settings.epsilon) {
      factor = 1; // tool centre does not move along a curve (control would reject this anyway)
    } else if (rw <= edgeFeed.settings.epsilon) {
      factor = Infinity;
    } else {
      factor = rc / rw;
    }
    return {factor:factor, centreRadius:rc, wallRadius:rw};
  },

  /** Clamps a factor and applies it to the feed. */
  applyFactor: function (feed, factor, limits) {
    var k = Math.max(limits.minFactor, Math.min(limits.maxFactor, factor));
    var f = feed * k;
    if ((limits.maxFeed > 0) && (k > 1)) {
      f = Math.min(f, Math.max(feed, limits.maxFeed)); // never raise above the max feed, never lower a programmed feed
    }
    return {feed:f, factor:f / feed, capped:(k != factor) || (f != feed * k)};
  },

  /**
    Fits a circle through 3 points in the XY plane.
    @return {radius, turn, angle, l1, l2} turn is +1 (left/CCW), -1 (right/CW) or 0 (straight), angle is the turn angle in radians
  */
  fitCircle: function (p0, p1, p2) {
    var ax = p1.x - p0.x, ay = p1.y - p0.y;
    var bx = p2.x - p1.x, by = p2.y - p1.y;
    var cx = p2.x - p0.x, cy = p2.y - p0.y;
    var l1 = Math.sqrt(ax * ax + ay * ay);
    var l2 = Math.sqrt(bx * bx + by * by);
    var l3 = Math.sqrt(cx * cx + cy * cy);
    var cross = ax * by - ay * bx;
    var dot = ax * bx + ay * by;
    var angle = Math.atan2(Math.abs(cross), dot);
    if ((l1 < edgeFeed.settings.epsilon) || (l2 < edgeFeed.settings.epsilon) || (Math.abs(cross) < 1e-15)) {
      return {radius:Infinity, turn:0, angle:0, l1:l1, l2:l2};
    }
    var radius = (l1 * l2 * l3) / (2 * Math.abs(cross));
    return {radius:radius, turn:(cross > 0) ? 1 : -1, angle:angle, l1:l1, l2:l2};
  },

  /** Returns the sagitta of a chord of the given length on a circle (Infinity if the chord does not fit). */
  sagitta: function (radius, chord) {
    if (!isFinite(radius)) {
      return 0;
    }
    var h = radius * radius - chord * chord / 4;
    return (h < 0) ? Infinity : radius - Math.sqrt(h);
  },

  /**
    Classifies the joint p1 between segments p0-p1 and p1-p2.
    @return {curve:boolean, radius, turn}
  */
  classifyJoint: function (p0, p1, p2, tolerance, margin) {
    var c = edgeFeed.fitCircle(p0, p1, p2);
    if ((c.turn == 0) || (c.angle < edgeFeed.settings.minTurnAngle)) {
      return {curve:false, radius:Infinity, turn:0};
    }
    var limit = tolerance * (1 + margin);
    var curve = (edgeFeed.sagitta(c.radius, c.l1) <= limit) && (edgeFeed.sagitta(c.radius, c.l2) <= limit);
    return {curve:curve, radius:c.radius, turn:c.turn};
  },

  /**
    Classifies segment p1-p2 from the joints at both of its ends.
    @return {curve:boolean, radius, turn}
  */
  classifySegment: function (p0, p1, p2, p3, tolerance, margin) {
    if (!p0 || !p3) {
      return {curve:false, radius:Infinity, turn:0}; // an end of a chain, not enough information
    }
    var a = edgeFeed.classifyJoint(p0, p1, p2, tolerance, margin);
    var b = edgeFeed.classifyJoint(p1, p2, p3, tolerance, margin);
    if (!a.curve || !b.curve || (a.turn != b.turn)) {
      return {curve:false, radius:Infinity, turn:0};
    }
    var ratio = Math.max(a.radius, b.radius) / Math.min(a.radius, b.radius);
    if (ratio > edgeFeed.settings.radiusRatio) {
      return {curve:false, radius:Infinity, turn:0};
    }
    return {curve:true, radius:(a.radius + b.radius) / 2, turn:a.turn};
  },

  /**
    Works out the side of the direction of travel where the wall is.
    @param parameters {compensation, direction, bothWays, clockwiseSpindle}
    @return {side:+1|-1|0, source:string} side 0 means unknown
  */
  wallSide: function (parameters) {
    if (parameters.compensation == "left") {
      return {side:-1, source:"compensation left"}; // tool on the left of the material, wall on the right
    }
    if (parameters.compensation == "right") {
      return {side:1, source:"compensation right"};
    }
    if (parameters.bothWays || (parameters.direction == "both ways")) { // adaptive uses bothWays, facing uses direction
      return {side:0, source:"both ways"};
    }
    var side;
    if (parameters.direction == "climb") {
      side = -1; // climb milling with M3: wall on the right
    } else if (parameters.direction == "conventional") {
      side = 1;
    } else {
      return {side:0, source:"no direction"};
    }
    if (!parameters.clockwiseSpindle) {
      side = -side;
    }
    return {side:side, source:parameters.direction + (parameters.clockwiseSpindle ? "" : " M4")};
  },

  /* ---------------------------------------------------------------------------------------------
     Post kernel integration
  --------------------------------------------------------------------------------------------- */

  /** Call once from onOpen(). */
  init: function (host) {
    edgeFeed.host = host;
    if (edgeFeed.settings.movements === undefined) {
      edgeFeed.settings.movements = [MOVEMENT_CUTTING, MOVEMENT_FINISH_CUTTING, MOVEMENT_REDUCED];
    }
    edgeFeed.state = {active:false};
    edgeFeed.buffer = undefined;
  },

  /** Returns true when the module adjusts feeds in the current section. */
  isActive: function () {
    return edgeFeed.state && edgeFeed.state.active;
  },

  /** Call from onSection(), after the tool has been selected. */
  onSection: function (section, sectionTool) {
    edgeFeed.flush();
    var s = {active:false, adjusted:0, capped:0, minFactor:Infinity, maxFactor:0};
    edgeFeed.state = s;
    if (!section.getProperty("edgeFeedEnable", false)) {
      return;
    }
    var name = section.hasParameter("operation-comment") ? section.getParameter("operation-comment") : ("#" + (section.getId() + 1));
    var skip = function (reason) {
      warning(subst("Edge feed not applied: %1.", reason)); // Fusion prefixes warnings with the operation name
    };
    var parameter = function (key, defaultValue) {
      return section.hasParameter(key) ? section.getParameter(key) : defaultValue;
    };
    if (section.isMultiAxis() || !section.isZOriented()) {
      skip("the tool axis is not along Z");
      return;
    }
    if (parameter("operation:isDrillingStrategy", 0) || parameter("operation:isProbingStrategy", 0) ||
      parameter("operation:isInspectionStrategy", 0) || parameter("operation:isTurningStrategy", 0)) {
      skip("not supported for this strategy");
      return;
    }
    var toolRadius = sectionTool.diameter / 2;
    if (!(toolRadius > 0)) {
      skip("the tool diameter is zero");
      return;
    }
    var side = edgeFeed.wallSide({
      compensation    : parameter("operation:compensation", undefined),
      direction       : parameter("operation:direction", undefined),
      bothWays        : parameter("operation:bothWays", 0) == 1,
      clockwiseSpindle: sectionTool.clockwise
    });
    if (side.side == 0) {
      skip((side.source == "both ways") ? "not available for operations that cut both ways" : "the wall side is unknown (" + side.source + ")");
      return;
    }
    var compensationType = parameter("operation:compensationType", "computer");
    s.active = true;
    s.name = name;
    s.toolRadius = toolRadius;
    s.side = side.side;
    s.sideSource = side.source;
    s.profilePosted = (compensationType == "control");
    s.tolerance = parameter("operation:tolerance", 0.01);
    s.margin = getProperty("edgeFeedSagittaMargin", 0.5);
    s.vertexSweep = getProperty("edgeFeedVertexSweep", 15) * Math.PI / 180;
    s.debug = getProperty("edgeFeedDebug", false);
    s.limits = {
      minFactor: getProperty("edgeFeedMinFactor", 0.1),
      maxFactor: section.getProperty("edgeFeedMaxFactor", 2),
      maxFeed  : getProperty("edgeFeedMaxFeed", 0)
    };
    if (s.debug && edgeFeed.host.writeComment) {
      edgeFeed.host.writeComment("EF " + EDGE_FEED_VERSION + " ON wall " + (s.side > 0 ? "left" : "right") +
        " (" + s.sideSource + ") r=" + s.toolRadius + " tol=" + s.tolerance + (s.profilePosted ? " profile posted" : ""));
    }
  },

  /** Returns the adjusted feed for a curve of the given posted radius and turn direction. */
  adjust: function (feed, postedRadius, turn, label) {
    var s = edgeFeed.state;
    var curve = edgeFeed.curveFactor(postedRadius, s.toolRadius, turn, s.side, s.profilePosted);
    var result = edgeFeed.applyFactor(feed, curve.factor, s.limits);
    s.adjusted++;
    if (result.capped) {
      s.capped++;
    }
    s.minFactor = Math.min(s.minFactor, result.factor);
    s.maxFactor = Math.max(s.maxFactor, result.factor);
    if (s.debug && edgeFeed.host.writeComment) {
      edgeFeed.host.writeComment("EF " + (label ? label + " " : "") + "R=" + edgeFeed.round(postedRadius) + " k=" + edgeFeed.round(result.factor) + (result.capped ? " capped" : ""));
    }
    return result.feed;
  },

  round: function (value) {
    return isFinite(value) ? Math.round(value * 1000) / 1000 : value;
  },

  isAdjustedMovement: function () {
    return edgeFeed.settings.movements.indexOf(movement) != -1;
  },

  /** Call from onCircular() before writing the arc. Returns the feed to output. */
  circularFeed: function (clockwise, cx, cy, cz, x, y, z, feed) {
    edgeFeed.flush();
    if (!edgeFeed.isActive() || !edgeFeed.isAdjustedMovement() || (getCircularPlane() != PLANE_XY)) {
      return feed;
    }
    return edgeFeed.adjust(feed, getCircularRadius(), clockwise ? -1 : 1);
  },

  /**
    Call from onLinear(). Returns true when the move has been taken into the look-ahead buffer, in which
    case the post must not output it (the module outputs it later through host.writeLinear).
  */
  onLinear: function (x, y, z, feed) {
    if (!edgeFeed.isActive()) {
      return false;
    }
    var start = getCurrentPosition();
    var end = {x:x, y:y, z:z};
    var dx = x - start.x, dy = y - start.y, dz = z - start.z;
    var xy = Math.sqrt(dx * dx + dy * dy);
    var length = Math.sqrt(xy * xy + dz * dz);
    if (length < edgeFeed.settings.epsilon) {
      edgeFeed.flush();
      return false; // feed-only record, let the post handle it
    }
    var segment = {
      type    : "line",
      start   : {x:start.x, y:start.y, z:start.z},
      end     : end,
      feed    : feed,
      eligible: edgeFeed.isAdjustedMovement() && (xy >= edgeFeed.settings.minXYFraction * length)
    };
    var b = edgeFeed.buffer;
    if (b && b.run) {
      b.run.push(segment); // inside a facet run, decided when the run ends
    } else if (b && b.pending) {
      edgeFeed.emitPending(end);
      b.previous = b.pending.start;
      b.pending = segment;
    } else {
      edgeFeed.buffer = {previous:undefined, pending:segment};
    }
    return true;
  },

  /** Outputs the buffered segment, using 'next' (the end of the following segment) as look-ahead. */
  emitPending: function (next) {
    var b = edgeFeed.buffer;
    var p = b.pending;
    var feed = p.feed;
    if (p.eligible) {
      var s = edgeFeed.state;
      var c = edgeFeed.classifySegment(b.previous, p.start, p.end, next, s.tolerance, s.margin);
      if (c.curve) {
        feed = edgeFeed.adjust(p.feed, c.radius, c.turn);
      }
    }
    edgeFeed.host.writeLinear(p.end.x, p.end.y, p.end.z, feed);
  },

  /**
    Call from onCircular() before anything else. Returns true when the arc is a corner roll that has been
    taken into the buffer, in which case the post must not output it (the module outputs it later through
    host.writeArcXY). A corner roll is the arc Fusion adds to roll the tool around a sharp outside corner:
    its radius is the tool radius, its centre is the part corner, and its sweep is the corner angle.
  */
  onCircular: function (clockwise, cx, cy, cz, x, y, z, feed) {
    var s = edgeFeed.state;
    if (!edgeFeed.isActive() || !edgeFeed.host.writeArcXY || s.profilePosted || !edgeFeed.isAdjustedMovement() ||
      (getCircularPlane() != PLANE_XY) || isFullCircle()) {
      return false;
    }
    var start = getCurrentPosition();
    var turn = clockwise ? -1 : 1;
    if ((Math.abs(z - start.z) > edgeFeed.settings.epsilon) || (turn != s.side) || // helical, or wall not on the inside
      (Math.abs(getCircularRadius() - s.toolRadius) > Math.max(s.tolerance, 0.001)) || // not a roll around a point
      (getCircularSweep() > s.vertexSweep)) { // a real corner
      return false;
    }
    var roll = {
      type     : "roll",
      clockwise: clockwise,
      cx       : cx,
      cy       : cy,
      start    : {x:start.x, y:start.y, z:start.z},
      end      : {x:x, y:y, z:z},
      feed     : feed,
      turn     : turn,
      radius   : getCircularRadius(),
      sweep    : getCircularSweep()
    };
    var b = edgeFeed.buffer;
    if (b && b.run) {
      b.run.push(roll);
    } else {
      var run = (b && b.pending) ? [b.pending] : []; // a pending line becomes the lead-in of the run, unchanged
      run.push(roll);
      edgeFeed.buffer = {run:run};
    }
    return true;
  },

  /**
    Outputs a facet run: corner rolls and the lines between them. Each roll gets the wall radius of the circle
    through its own corner and its neighbouring corners, and each line the mean of the corners at its ends.
    The first and last roll of a run have only one neighbour and keep the wall radius of the nearest fitted
    roll, so the feed runs smoothly into and out of the curve. With only two rolls the radius is estimated from
    the facets between them. A single roll between lines is a real corner and gets the max factor.
  */
  emitRun: function (run) {
    var s = edgeFeed.state;
    var rolls = [];
    for (var i = 0; i < run.length; ++i) {
      if (run[i].type == "roll") {
        rolls.push(i);
      }
    }
    for (var k = 0; k < rolls.length; ++k) {
      var r = run[rolls[k]];
      r.wallRadius = undefined;
      if ((k > 0) && (k < rolls.length - 1)) {
        var a = run[rolls[k - 1]], c = run[rolls[k + 1]];
        var fit = edgeFeed.fitCircle({x:a.cx, y:a.cy}, {x:r.cx, y:r.cy}, {x:c.cx, y:c.cy});
        if ((fit.turn == r.turn) && (a.turn == r.turn) && (c.turn == r.turn) && isFinite(fit.radius)) {
          r.wallRadius = fit.radius;
        }
      }
    }
    if (rolls.length > 1) { // a single roll between lines is a real corner; otherwise every roll is part of the curve
      var fitted = [];
      for (k = 0; k < rolls.length; ++k) {
        if (run[rolls[k]].wallRadius !== undefined) {
          fitted.push(k);
        }
      }
      var estimate = (fitted.length == 0) ? edgeFeed.runRadius(run, rolls) : undefined;
      for (k = 0; k < rolls.length; ++k) {
        var roll = run[rolls[k]];
        if (roll.wallRadius !== undefined) {
          continue;
        }
        if (fitted.length == 0) {
          roll.wallRadius = estimate; // too few rolls to fit a circle
        } else { // the ends of the curve keep the radius of the nearest fitted roll, so the feed stays smooth
          var best = fitted[0];
          for (var f = 1; f < fitted.length; ++f) {
            if (Math.abs(fitted[f] - k) < Math.abs(best - k)) {
              best = fitted[f];
            }
          }
          roll.wallRadius = run[rolls[best]].wallRadius;
        }
      }
    }
    var previousRoll; // the last roll before the current item
    for (var j = 0; j < run.length; ++j) {
      var item = run[j];
      var feed = item.feed;
      if (item.type == "roll") {
        if (item.wallRadius !== undefined) {
          feed = edgeFeed.adjust(item.feed, item.wallRadius + s.toolRadius, item.turn, "facet");
        } else {
          feed = edgeFeed.adjust(item.feed, item.radius, item.turn, "corner"); // wall radius ~0, max factor
        }
        edgeFeed.host.writeArcXY(item.clockwise, item.cx, item.cy, item.end.x, item.end.y, item.end.z, feed, item.start);
        previousRoll = item;
      } else {
        var nextRoll = undefined; // var is function-scoped: reset for every line
        for (var n = j + 1; n < run.length; ++n) {
          if (run[n].type == "roll") {
            nextRoll = run[n];
            break;
          }
        }
        if (item.eligible && previousRoll && nextRoll && (previousRoll.wallRadius !== undefined) && (nextRoll.wallRadius !== undefined)) {
          feed = edgeFeed.adjust(item.feed, (previousRoll.wallRadius + nextRoll.wallRadius) / 2 + s.toolRadius, previousRoll.turn, "facet");
        }
        edgeFeed.host.writeLinear(item.end.x, item.end.y, item.end.z, feed);
      }
    }
  },

  /**
    Wall radius of a run too short to fit circles, from the facet lines between its first and last roll and the
    mean roll sweep: a polygon with sides L turning by a at each corner lies on a circle R = L / (2 sin(a / 2)).
    Returns 0 (a corner) when there is nothing to measure.
  */
  runRadius: function (run, rolls) {
    var length = 0, facets = 0, sweep = 0;
    for (var i = rolls[0] + 1; i < rolls[rolls.length - 1]; ++i) {
      if (run[i].type == "line") {
        var dx = run[i].end.x - run[i].start.x, dy = run[i].end.y - run[i].start.y;
        length += Math.sqrt(dx * dx + dy * dy);
        ++facets;
      }
    }
    for (var k = 0; k < rolls.length; ++k) {
      sweep += run[rolls[k]].sweep / rolls.length;
    }
    if ((facets == 0) || !(sweep > 1e-9)) {
      return 0;
    }
    return (length / facets) / (2 * Math.sin(sweep / 2));
  },

  /** Outputs any buffered move. Call from every entry point that writes output. */
  flush: function () {
    var b = edgeFeed.buffer;
    edgeFeed.buffer = undefined;
    if (b && b.run) {
      edgeFeed.emitRun(b.run);
    } else if (b && b.pending) {
      edgeFeed.buffer = b;
      edgeFeed.emitPending(undefined); // the end of a chain is never adjusted
      edgeFeed.buffer = undefined;
    }
  },

  /** Call from onSectionEnd(). */
  onSectionEnd: function () {
    edgeFeed.flush();
    var s = edgeFeed.state;
    if (s && s.active && s.debug && edgeFeed.host.writeComment) {
      edgeFeed.host.writeComment("EF " + s.adjusted + " moves adjusted" +
        (s.adjusted > 0 ? ", k " + edgeFeed.round(s.minFactor) + " to " + edgeFeed.round(s.maxFactor) + ", " + s.capped + " capped" : ""));
    }
    edgeFeed.state = {active:false};
  }
};
// <<<<< INCLUDED FROM edgeFeed.cpi
edgeFeedMergeProperties(properties);

var singleLineCoolant = false; // specifies to output multiple coolant codes in one line rather than in separate lines
// samples:
// {id: COOLANT_THROUGH_TOOL, on: 88, off: 89}
// {id: COOLANT_THROUGH_TOOL, on: [8, 88], off: [9, 89]}
var coolants = [
  {id: COOLANT_FLOOD, on: 8},
  {id: COOLANT_MIST},
  {id: COOLANT_THROUGH_TOOL, on: 88},
  {id: COOLANT_AIR},
  {id: COOLANT_AIR_THROUGH_TOOL},
  {id: COOLANT_SUCTION},
  {id: COOLANT_FLOOD_MIST},
  {id: COOLANT_FLOOD_THROUGH_TOOL},
  {id: COOLANT_OFF, off: 9}
];

var gFormat = createFormat({prefix:"G", decimals:1});
var mFormat = createFormat({prefix:"M", decimals:0});
var hFormat = createFormat({prefix:"", decimals:0});
var dFormat = createFormat({prefix:"D", decimals:0});
var probe100Format = createFormat({decimals:3, zeropad:true, width:3, forceDecimal:true});

var xyzFormat = createFormat({decimals:(unit == MM ? 3 : 4), forceDecimal:true});
var ijkFormat = createFormat({decimals:6, forceDecimal:true});
var abcFormat = createFormat({decimals:3, forceDecimal:true, scale:DEG});
var feedFormat = createFormat({decimals:(unit == MM ? 1 : 2), forceDecimal:true});
var toolFormat = createFormat({decimals:0});
var rpmFormat = createFormat({decimals:0});
var secFormat = createFormat({decimals:3, forceDecimal:true}); // seconds - range 0.001-9999.999
var taperFormat = createFormat({decimals:1, scale:DEG});

var xOutput = createVariable({prefix:"X"}, xyzFormat);
var yOutput = createVariable({prefix:"Y"}, xyzFormat);
var zOutput = createVariable({onchange:function () {retracted = false;}, prefix:"Z"}, xyzFormat);
var aOutput = createVariable({prefix:"A"}, abcFormat);
var bOutput = createVariable({prefix:"B"}, abcFormat);
var cOutput = createVariable({prefix:"C"}, abcFormat);
var feedOutput = createVariable({prefix:"F"}, feedFormat);
var sOutput = createVariable({prefix:"S", force:true}, rpmFormat);
var dOutput = createVariable({}, dFormat);

// circular output
var iOutput = createVariable({prefix:"I", force:true}, xyzFormat);
var jOutput = createVariable({prefix:"J", force:true}, xyzFormat);
var kOutput = createVariable({prefix:"K", force:true}, xyzFormat);
var irOutput = createReferenceVariable({prefix:"I", force:true}, xyzFormat);
var jrOutput = createReferenceVariable({prefix:"J", force:true}, xyzFormat);
var krOutput = createReferenceVariable({prefix:"K", force:true}, xyzFormat);

var gMotionModal = createModal({}, gFormat); // modal group 1 // G0-G3, ...
var gPlaneModal = createModal({onchange:function () {gMotionModal.reset();}}, gFormat); // modal group 2 // G17-19
var gAbsIncModal = createModal({}, gFormat); // modal group 3 // G90-91
var gUnitModal = createModal({}, gFormat); // modal group 6 // G20-21 or G70-71
var gCycleModal = createModal({}, gFormat); // modal group 9 // G81, ...
var gRetractModal = createModal({}, gFormat); // modal group 10 // G98-99
var gRotationModal = createModal({}, gFormat); // modal group 16 // G68-G69

// fixed settings
var firstFeedParameter = 1;
var useMultiAxisFeatures = true;
var forceMultiAxisIndexing = false; // force multi-axis indexing for 3D programs

var ANGLE_PROBE_NOT_SUPPORTED = 0;
var ANGLE_PROBE_USE_ROTATION = 1;
var ANGLE_PROBE_USE_CAXIS = 2;

var WARNING_WORK_OFFSET = 0;

// collected state
var sequenceNumber;
var currentWorkOffset;
var forceSpindleSpeed = false;
var activeMovements; // do not use by default
var currentFeedId;
var g68RotationMode = 0;
var angularProbingMode;
var retracted = false; // specifies that the tool has been retracted to the safe plane
probeMultipleFeatures = true;

/** Returns true if the given ABC axis is available for use with vector output. */
function hasABCAxis(name) {
  return String(getProperty("machineAxisABC")).toUpperCase().indexOf(name) != -1;
}

/**
  Writes the specified block.
*/
function writeBlock() {
  var text = formatWords(arguments);
  if (!text) {
    return;
  }
  if (getProperty("showSequenceNumbers")) {
    if (text) {
      if (sequenceNumber > 9999999) {
        sequenceNumber = getProperty("sequenceNumberStart");
      }
      writeWords2("N" + sequenceNumber, text);
      sequenceNumber += getProperty("sequenceNumberIncrement");
    }
  } else {
    writeWords(arguments);
  }
}

function formatComment(text) {
  return "(" + String(text).replace(/[()]/g, "") + ")";
}

/**
  Output a comment.
*/
function writeComment(text) {
  writeln(formatComment(text));
}

// machine coordinate (G53) positions, shared between NC output and machine simulation
var frontPosition = {x:300, y:405}; // 'front' manual NC pass-through
var parkPosition = {x:300, y:400}; // end of program park

//manually add gcode using manual nc pass through command
function onPassThrough(text) {
  edgeFeed.flush();
  var commands = String(text).split(",");
  for (text in commands) {
    if(commands[text]==='front'){
      writeComment("Move to front");
      setCoolant(COOLANT_OFF);
      writeBlock(gFormat.format(53), gMotionModal.format(0), zOutput.format(0));
      machineSimulation({z:0, coordinates:MACHINE});
      writeBlock(gFormat.format(53), gMotionModal.format(0), xOutput.format(frontPosition.x), yOutput.format(frontPosition.y));
      machineSimulation({x:frontPosition.x, y:frontPosition.y, coordinates:MACHINE});
      writeBlock(mFormat.format(0));
      // writeBlock(yOutput.format(333));
    }else{
      writeBlock(commands[text]);
    }
  }
}

//function to print out file path, with catch to split across 2 messages if path name is too long
function writeDprntFilePath(path) {
  var cleanPath = path.replace(/\\/g, "/").replace(/\./g, "+").replace(/&/g, "and").replace(/’/g, "'");
  var header = "LOG-HURCO VM10I-FILENAME-";
  var maxLength = 112 - header.length; // 87 chars for path

  if (cleanPath.length <= maxLength) {
    writeln("DPRNT[" + header + cleanPath + "]");
  } else {
    writeln("DPRNT[" + header + cleanPath.substring(0, maxLength) + "]");
    writeln("DPRNT[LOG-HURCO VM10I-FILENAME CONT-" + cleanPath.substring(maxLength) + "]");
  }
}

function onOpen() {
  edgeFeed.init({writeLinear:writeLinear, writeArcXY:writeArcXY, writeComment:writeComment});

  if (getProperty("isnc") && (highFeedrate <= 0)) {
    error(localize("You must set 'highFeedrate' because axes are not synchronized in HURCO ISO NC mode."));
    return;
  }

  if (false) { // note: setup your machine here
    var aAxis = createAxis({coordinate:0, table:false, axis:[1, 0, 0], range:[-360, 360], preference:1});
    var cAxis = createAxis({coordinate:2, table:false, axis:[0, 0, 1], range:[-360, 360], preference:1});
    machineConfiguration = new MachineConfiguration(aAxis, cAxis);

    setMachineConfiguration(machineConfiguration);
    optimizeMachineAngles2(0); // TCP mode
  }

  if (!machineConfiguration.isMachineCoordinate(0)) {
    aOutput.disable();
  }
  if (!machineConfiguration.isMachineCoordinate(1)) {
    bOutput.disable();
  }
  if (!machineConfiguration.isMachineCoordinate(2)) {
    cOutput.disable();
  }
  
  if (useMultiAxisFeatures && !machineConfiguration.isMultiAxisConfiguration()) {
    var text = String(getProperty("machineAxisABC")).toUpperCase();
    for (var i = 0; i < text.length; ++i) {
      if ("ABC".indexOf(text.charAt(i)) == -1) {
        error(localize("Property 'machineAxisABC' must be A, B, C or any combination of these axes!"));
        return;
      }
    }
  }
  
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
    }
    var oFormat = createFormat({width:4, zeropad:true, decimals:0});
    writeln(
      "O" + oFormat.format(programId) +
      conditional(programComment, " " + formatComment(programComment))
    );
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

  //Probing Surface Inspection
  if (typeof inspectionWriteVariables == "function") {
    inspectionWriteVariables();
  }

  // dump tool information
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
        var comment = "T" + toolFormat.format(tool.number) + " " +
          "D=" + xyzFormat.format(tool.diameter) + " " +
          localize("CR") + "=" + xyzFormat.format(tool.cornerRadius);
        if ((tool.taperAngle > 0) && (tool.taperAngle < Math.PI)) {
          comment += " " + localize("TAPER") + "=" + taperFormat.format(tool.taperAngle) + localize("deg");
        }
        if (zRanges[tool.number]) {
          comment += " - " + localize("ZMIN") + "=" + xyzFormat.format(zRanges[tool.number].getMinimum());
        }
        comment += " - " + getToolTypeName(tool.type);
        writeComment(comment);
      }
    }
  }
  
  if (false) {
    // check for duplicate tool number
    for (var i = 0; i < getNumberOfSections(); ++i) {
      var sectioni = getSection(i);
      var tooli = sectioni.getTool();
      for (var j = i + 1; j < getNumberOfSections(); ++j) {
        var sectionj = getSection(j);
        var toolj = sectionj.getTool();
        if (tooli.number == toolj.number) {
          if (xyzFormat.areDifferent(tooli.diameter, toolj.diameter) ||
              xyzFormat.areDifferent(tooli.cornerRadius, toolj.cornerRadius) ||
              abcFormat.areDifferent(tooli.taperAngle, toolj.taperAngle) ||
              (tooli.numberOfFlutes != toolj.numberOfFlutes)) {
            error(
              subst(
                localize("Using the same tool number for different cutter geometry for operation '%1' and '%2'."),
                sectioni.hasParameter("operation-comment") ? sectioni.getParameter("operation-comment") : ("#" + (i + 1)),
                sectionj.hasParameter("operation-comment") ? sectionj.getParameter("operation-comment") : ("#" + (j + 1))
              )
            );
            return;
          }
        }
      }
    }
  }
  
  if (useMultiAxisFeatures && !machineConfiguration.isMultiAxisConfiguration() && isMultiAxis()) {
    onCommand(COMMAND_STOP);
    onComment("We cannot guarantee that the CNC will not have to do a rewind during cutting when using vector output.");
    onComment("Machine needs to be defined in post to use ABC output and hence avoid risk of gouges during rewind. Please be careful.");
  }

  if ((getNumberOfSections() > 0) && (getSection(0).workOffset == 0)) {
    for (var i = 0; i < getNumberOfSections(); ++i) {
      if (getSection(i).workOffset > 0) {
        error(localize("Using multiple work offsets is not possible if the initial work offset is 0."));
        return;
      }
    }
  }

  // absolute coordinates and feed per min
  writeBlock(gAbsIncModal.format(90), gPlaneModal.format(17));
  if (!getProperty("isnc")) {
    writeBlock(gAbsIncModal.format(75)); // multi-quadrant arc interpolation mode
  }

  switch (unit) {
  case IN:
    writeBlock(gUnitModal.format(getProperty("isnc") ? 20 : 70));
    break;
  case MM:
    writeBlock(gUnitModal.format(getProperty("isnc") ? 21 : 71));
    break;
  }
  onCommand(COMMAND_START_CHIP_TRANSPORT);
  
  if (useMultiAxisFeatures && (forceMultiAxisIndexing || !is3D() || machineConfiguration.isMultiAxisConfiguration())) {
    writeBlock(mFormat.format(31)); // rotary axes encoder reset
    writeBlock(mFormat.format(126)); // shortest path traverse
  }
  // DPRNT logging - program start
  writeln("POPEN");
  writeln("DPRNT[LOG-HURCO VM10I-PROGRAM START-O" + oFormat.format(programId) + "]");
  writeDprntFilePath(getOutputPath());
  // writeln("DPRNT[LOG-HURCO VM10I-FILENAME-" + getOutputPath().replace(/\\/g, "/").replace(/\./g, "+") + "]");
}

function onComment(message) {
  edgeFeed.flush();
  writeComment(message);
}

/** Force output of X, Y, and Z. */
function forceXYZ() {
  xOutput.reset();
  yOutput.reset();
  zOutput.reset();
}

/** Force output of A, B, and C. */
function forceABC() {
  aOutput.reset();
  bOutput.reset();
  cOutput.reset();
}

function forceFeed() {
  currentFeedId = undefined;
  feedOutput.reset();
}

/** Force output of X, Y, Z, A, B, C, and F on next output. */
function forceAny() {
  forceXYZ();
  forceABC();
  forceFeed();
}

function isProbeOperation() {
  return hasParameter("operation-strategy") && ((getParameter("operation-strategy") == "probe" || getParameter("operation-strategy") == "probe_geometry"));
}

function isInspectionOperation(section) {
  return section.hasParameter("operation-strategy") && (section.getParameter("operation-strategy") == "inspectSurface");
}

var probeOutputWorkOffset = 1;

function onParameter(name, value) {
  if (name == "probe-output-work-offset") {
    probeOutputWorkOffset = (value > 0) ? value : 1;
  }
}

function FeedContext(id, description, feed) {
  this.id = id;
  this.description = description;
  this.feed = feed;
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
  return feedOutput.format(f); // use feed value
}

function initializeActiveFeeds() {
  activeMovements = new Array();
  var movements = currentSection.getMovements();
  
  var id = 0;
  var activeFeeds = new Array();
  if (hasParameter("operation:tool_feedCutting")) {
    if (movements & ((1 << MOVEMENT_CUTTING) | (1 << MOVEMENT_LINK_TRANSITION) | (1 << MOVEMENT_EXTENDED))) {
      var feedContext = new FeedContext(id, localize("Cutting"), getParameter("operation:tool_feedCutting"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_CUTTING] = feedContext;
      activeMovements[MOVEMENT_LINK_TRANSITION] = feedContext;
      activeMovements[MOVEMENT_EXTENDED] = feedContext;
    }
    ++id;
    if (movements & (1 << MOVEMENT_PREDRILL)) {
      feedContext = new FeedContext(id, localize("Predrilling"), getParameter("operation:tool_feedCutting"));
      activeMovements[MOVEMENT_PREDRILL] = feedContext;
      activeFeeds.push(feedContext);
    }
    ++id;
  }
  
  if (hasParameter("operation:finishFeedrate")) {
    if (movements & (1 << MOVEMENT_FINISH_CUTTING)) {
      var feedContext = new FeedContext(id, localize("Finish"), getParameter("operation:finishFeedrate"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_FINISH_CUTTING] = feedContext;
    }
    ++id;
  } else if (hasParameter("operation:tool_feedCutting")) {
    if (movements & (1 << MOVEMENT_FINISH_CUTTING)) {
      var feedContext = new FeedContext(id, localize("Finish"), getParameter("operation:tool_feedCutting"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_FINISH_CUTTING] = feedContext;
    }
    ++id;
  }
  
  if (hasParameter("operation:tool_feedEntry")) {
    if (movements & (1 << MOVEMENT_LEAD_IN)) {
      var feedContext = new FeedContext(id, localize("Entry"), getParameter("operation:tool_feedEntry"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_LEAD_IN] = feedContext;
    }
    ++id;
  }

  if (hasParameter("operation:tool_feedExit")) {
    if (movements & (1 << MOVEMENT_LEAD_OUT)) {
      var feedContext = new FeedContext(id, localize("Exit"), getParameter("operation:tool_feedExit"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_LEAD_OUT] = feedContext;
    }
    ++id;
  }

  if (hasParameter("operation:noEngagementFeedrate")) {
    if (movements & (1 << MOVEMENT_LINK_DIRECT)) {
      var feedContext = new FeedContext(id, localize("Direct"), getParameter("operation:noEngagementFeedrate"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_LINK_DIRECT] = feedContext;
    }
    ++id;
  } else if (hasParameter("operation:tool_feedCutting") &&
             hasParameter("operation:tool_feedEntry") &&
             hasParameter("operation:tool_feedExit")) {
    if (movements & (1 << MOVEMENT_LINK_DIRECT)) {
      var feedContext = new FeedContext(id, localize("Direct"), Math.max(getParameter("operation:tool_feedCutting"), getParameter("operation:tool_feedEntry"), getParameter("operation:tool_feedExit")));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_LINK_DIRECT] = feedContext;
    }
    ++id;
  }
  
  if (hasParameter("operation:reducedFeedrate")) {
    if (movements & (1 << MOVEMENT_REDUCED)) {
      var feedContext = new FeedContext(id, localize("Reduced"), getParameter("operation:reducedFeedrate"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_REDUCED] = feedContext;
    }
    ++id;
  }

  if (hasParameter("operation:tool_feedRamp")) {
    if (movements & ((1 << MOVEMENT_RAMP) | (1 << MOVEMENT_RAMP_HELIX) | (1 << MOVEMENT_RAMP_PROFILE) | (1 << MOVEMENT_RAMP_ZIG_ZAG))) {
      var feedContext = new FeedContext(id, localize("Ramping"), getParameter("operation:tool_feedRamp"));
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
      var feedContext = new FeedContext(id, localize("Plunge"), getParameter("operation:tool_feedPlunge"));
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
  
  for (var i = 0; i < activeFeeds.length; ++i) {
    var feedContext = activeFeeds[i];
    writeBlock("#" + (firstFeedParameter + feedContext.id) + "=" + feedFormat.format(feedContext.feed), formatComment(feedContext.description));
  }
}

var currentWorkPlaneABC = undefined;

function forceWorkPlane() {
  currentWorkPlaneABC = undefined;
}

function setWorkPlane(abc) {
  if (!forceMultiAxisIndexing && is3D() && !machineConfiguration.isMultiAxisConfiguration()) {
    return; // ignore
  }
  if (forceMultiAxisIndexing) {
    forceWorkPlane();
  }
  
  if (!((currentWorkPlaneABC == undefined) ||
        (machineConfiguration.isMultiAxisConfiguration() ? abcFormat.areDifferent(abc.x, currentWorkPlaneABC.x) : ijkFormat.areDifferent(abc.x, currentWorkPlaneABC.x)) ||
        (machineConfiguration.isMultiAxisConfiguration() ? abcFormat.areDifferent(abc.y, currentWorkPlaneABC.y) : ijkFormat.areDifferent(abc.y, currentWorkPlaneABC.y)) ||
        (machineConfiguration.isMultiAxisConfiguration() ? abcFormat.areDifferent(abc.z, currentWorkPlaneABC.z) : ijkFormat.areDifferent(abc.z, currentWorkPlaneABC.z)))) {
    return; // no change
  }
  
  onCommand(COMMAND_UNLOCK_MULTI_AXIS);

  if (useMultiAxisFeatures) {
    if (true) { // we don't want to use G69 for reset alone
      writeBlock(gFormat.format(0), mFormat.format(140)); // retract along tool vector
      writeBlock(gFormat.format(69)); // cancel frame
      gMotionModal.reset();
      var initialPosition = getFramePosition(currentSection.getInitialPosition()); // TAG
      var W = currentSection.workPlane;
      if (!machineConfiguration.isMultiAxisConfiguration()) {
        writeBlock(
          gFormat.format(68.2),
          "X" + xyzFormat.format(currentSection.workOrigin.x),
          "Y" + xyzFormat.format(currentSection.workOrigin.y),
          "Z" + xyzFormat.format(currentSection.workOrigin.z),
          "I" + ijkFormat.format(W.right.x), "J" + ijkFormat.format(W.right.y), "K" + ijkFormat.format(W.right.z),
          "U" + ijkFormat.format(W.up.x), "V" + ijkFormat.format(W.up.y), "W" + ijkFormat.format(W.up.z)
        ); // set frame
        var d = currentSection.getInitialToolAxis();
        writeBlock(
          gMotionModal.format(0), gFormat.format(8.2),
          xOutput.format(initialPosition.x), yOutput.format(initialPosition.y), zOutput.format(initialPosition.z),
          "I" + ijkFormat.format(d.x), "J" + ijkFormat.format(d.y), "K" + ijkFormat.format(d.z)
        );
      } else {
        writeBlock(
          gMotionModal.format(0),
          conditional(machineConfiguration.isMachineCoordinate(0), "A" + abcFormat.format(abc.x)),
          conditional(machineConfiguration.isMachineCoordinate(1), "B" + abcFormat.format(abc.y)),
          conditional(machineConfiguration.isMachineCoordinate(2), "C" + abcFormat.format(abc.z))
        );
        writeBlock(
          gFormat.format(68.2),
          "X" + xyzFormat.format(currentSection.workOrigin.x),
          "Y" + xyzFormat.format(currentSection.workOrigin.y),
          "Z" + xyzFormat.format(currentSection.workOrigin.z),
          conditional(machineConfiguration.isMachineCoordinate(0), "A" + abcFormat.format(abc.x)),
          conditional(machineConfiguration.isMachineCoordinate(1), "B" + abcFormat.format(abc.y)),
          conditional(machineConfiguration.isMachineCoordinate(2), "C" + abcFormat.format(abc.z))
        ); // set frame
        writeBlock(
          gMotionModal.format(0), gFormat.format(8.2),
          xOutput.format(initialPosition.x), yOutput.format(initialPosition.y), zOutput.format(initialPosition.z)
        );
      }
      // writeBlock(mFormat.format(141));
    } else {
      writeBlock(gFormat.format(69)); // cancel frame
    }
  } else {
    gMotionModal.reset();
    writeBlock(
      gMotionModal.format(0),
      conditional(machineConfiguration.isMachineCoordinate(0), "A" + abcFormat.format(abc.x)),
      conditional(machineConfiguration.isMachineCoordinate(1), "B" + abcFormat.format(abc.y)),
      conditional(machineConfiguration.isMachineCoordinate(2), "C" + abcFormat.format(abc.z))
    );
  }
  
  onCommand(COMMAND_LOCK_MULTI_AXIS);

  currentWorkPlaneABC = abc;
}

var closestABC = false; // choose closest machine angles
var currentMachineABC;

function getWorkPlaneMachineABC(workPlane) {
  var W = workPlane; // map to global frame

  var abc = machineConfiguration.getABC(W);
  if (closestABC) {
    if (currentMachineABC) {
      abc = machineConfiguration.remapToABC(abc, currentMachineABC);
    } else {
      abc = machineConfiguration.getPreferredABC(abc);
    }
  } else {
    abc = machineConfiguration.getPreferredABC(abc);
  }
  
  try {
    abc = machineConfiguration.remapABC(abc);
    currentMachineABC = abc;
  } catch (e) {
    error(
      localize("Machine angles not supported") + ":"
      + conditional(machineConfiguration.isMachineCoordinate(0), " A" + abcFormat.format(abc.x))
      + conditional(machineConfiguration.isMachineCoordinate(1), " B" + abcFormat.format(abc.y))
      + conditional(machineConfiguration.isMachineCoordinate(2), " C" + abcFormat.format(abc.z))
    );
  }
  
  var direction = machineConfiguration.getDirection(abc);
  if (!isSameDirection(direction, W.forward)) {
    error(localize("Orientation not supported."));
  }
  
  if (!machineConfiguration.isABCSupported(abc)) {
    error(
      localize("Work plane is not supported") + ":"
      + conditional(machineConfiguration.isMachineCoordinate(0), " A" + abcFormat.format(abc.x))
      + conditional(machineConfiguration.isMachineCoordinate(1), " B" + abcFormat.format(abc.y))
      + conditional(machineConfiguration.isMachineCoordinate(2), " C" + abcFormat.format(abc.z))
    );
  }

  var tcp = false;
  if (tcp) {
    setRotation(W); // TCP mode
  } else {
    var O = machineConfiguration.getOrientation(abc);
    var R = machineConfiguration.getRemainingOrientation(abc, W);
    setRotation(R);
  }
  
  return abc;
}

var isBroach = false;
var isAlignmentOp = false;
var isDispenser = false; //flag to see if it is magnet or adhesive dispenser
var isRefill = false; //flag for adhesive dispenser refilling

function onSection() {
  var insertToolCall = isFirstSection() ||
    currentSection.getForceToolChange && currentSection.getForceToolChange() ||
    (tool.number != getPreviousSection().getTool().number);
  
  retracted = false; // specifies that the tool has been retracted to the safe plane
  var newWorkOffset = isFirstSection() ||
    (getPreviousSection().workOffset != currentSection.workOffset); // work offset changes
  var newWorkPlane = isFirstSection() ||
    !isSameDirection(getPreviousSection().getGlobalFinalToolAxis(), currentSection.getGlobalInitialToolAxis()) ||
    (currentSection.isOptimizedForMachine() && getPreviousSection().isOptimizedForMachine() &&
      Vector.diff(getPreviousSection().getFinalToolAxisABC(), currentSection.getInitialToolAxisABC()).length > 1e-4) ||
    (!machineConfiguration.isMultiAxisConfiguration() && currentSection.isMultiAxis()) ||
    (!getPreviousSection().isMultiAxis() && currentSection.isMultiAxis() ||
      getPreviousSection().isMultiAxis() && !currentSection.isMultiAxis()); // force newWorkPlane between indexing and simultaneous operations
  if (insertToolCall || newWorkOffset || newWorkPlane) {
    nullProbeAngle(true);
    
    // stop spindle before retract during tool change
    if (insertToolCall && !isFirstSection()) {
      onCommand(COMMAND_STOP_SPINDLE);
    }
    
    // retract to safe plane
    writeRetract(Z);
    forceXYZ();
    
    // save tool change position
    if (insertToolCall && !isFirstSection()) {
      if (getProperty("safeToolChangePositionX") || getProperty("safeToolChangePositionY")) {
        writeBlock(gFormat.format(53), conditional(getProperty("safeToolChangePositionX"), "X" + xyzFormat.format(0)), conditional(getProperty("safeToolChangePositionY"), "Y" + xyzFormat.format(0)));
        machineSimulation({
          x          : getProperty("safeToolChangePositionX") ? 0 : undefined,
          y          : getProperty("safeToolChangePositionY") ? 0 : undefined,
          coordinates: MACHINE,
          feed       : false
        });
      }
    }
  }

  if (hasParameter("operation-comment")) { //This writes a comment with the operation name
    var comment = getParameter("operation-comment");
    if (comment) {
      writeComment(comment);
      // writeComment("strategy: " + getParameter("operation-strategy"));//currentSection.getId());
    }
  }

  if(tool.comment==="broach"||(tool.comment).startsWith("broach")){
    isBroach = true;
    writeComment("it's a broach operation");
    if(getParameter("operation-strategy")==="path3d"){
      isAlignmentOp = true;
      writeComment("it's an alignment operation");
    }else{
      var initialPosition = getFramePosition(currentSection.getInitialPosition());
      
      // writeBlock("G54");
      // writeBlock(gMotionModal.format(0), xOutput.format(initialPosition.x), yOutput.format(initialPosition.y));
      // writeBlock(gMotionModal.format(0), gFormat.format(43), zOutput.format(initialPosition.z));
      // writeBlock(gMotionModal.format(1), zOutput.format(cycle.retract), feedOutput.format(cycle.feedrate));
      // writeComment(cycle.retract);
      // writeBlock(
      //   gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(85),
      //   getCommonCycle(xOutput.format(initialPosition.x), yOutput.format(initialPosition.y), z, cycle.retract),
      //   feedOutput.format(cycle.feedrate)
      // );
      writeBlock("M1");
    }
  }else{
    isBroach=false;
  }

  if(tool.comment==="dispenser"){
    isDispenser = true;
    if(getParameter("operation-comment")==="refill"){
      isRefill = true;
    }
  }
  
  if (getProperty("showNotes") && hasParameter("notes")) {
    var notes = getParameter("notes");
    if (notes) {
      var lines = String(notes).split("\n");
      var r1 = new RegExp("^[\\s]+", "g");
      var r2 = new RegExp("[\\s]+$", "g");
      for (line in lines) {
        var comment = lines[line].replace(r1, "").replace(r2, "");
        if (comment) {
          writeComment(comment);
        }
      }
    }
  }
  
  if (insertToolCall) {
    forceWorkPlane();
  
    if (!isFirstSection()) {
      setCoolant(COOLANT_OFF);
      if (getProperty("optionalStop")) {
        onCommand(COMMAND_OPTIONAL_STOP);
      }
    }

    if (tool.number > 9999) {
      warning(localize("Tool number exceeds maximum value."));
    }

    writeBlock("T" + toolFormat.format(tool.number), mFormat.format(6));
    machineSimulation({mode:TOOLCHANGE}); // perform tool change cycle in machine simulation
    writeln("DPRNT[LOG-HURCO VM10I-TOOL CHANGE-T" + toolFormat.format(tool.number) + "]");

    if (tool.comment) {
      writeComment(tool.comment);
    }
    var showToolZMin = false;
    if (showToolZMin) {
      if (is3D()) {
        var numberOfSections = getNumberOfSections();
        var zRange = currentSection.getGlobalZRange();
        var number = tool.number;
        for (var i = currentSection.getId() + 1; i < numberOfSections; ++i) {
          var section = getSection(i);
          if (section.getTool().number != number) {
            break;
          }
          zRange.expandToRange(section.getGlobalZRange());
        }
        writeComment(localize("ZMIN") + "=" + zRange.getMinimum());
      }
    }

    if (getProperty("preloadTool")) {
      var nextTool = getNextTool(tool.number);
      if (nextTool) {
        writeBlock("T" + toolFormat.format(nextTool.number));
      } else {
        // preload first tool
        var section = getSection(0);
        var firstToolNumber = section.getTool().number;
        if (tool.number != firstToolNumber) {
          writeBlock("T" + toolFormat.format(firstToolNumber));
        }
      }
    }
    if (isProbeOperation() || isInspectionOperation(currentSection)) {
      if (getProperty("isnc")) {
        writeBlock(mFormat.format(19)); // spindle orientation
        writeBlock(mFormat.format(26)); // select the part probe, M27 is selecting the tool probe
        writeBlock(mFormat.format(41)); // Single touch probing, M42 is 2 touch probing
      } else {
        error(localize("Probing or surface inspection is only allowed in ISNC mode!"));
      }
    }
  }
  
  if (!isProbeOperation() &&
      !isInspectionOperation(currentSection) && (insertToolCall ||
      forceSpindleSpeed ||
      isFirstSection() ||
      (rpmFormat.areDifferent(spindleSpeed, sOutput.getCurrent())) ||
      (tool.clockwise != getPreviousSection().getTool().clockwise))) {
    forceSpindleSpeed = false;
    
    if (spindleSpeed < 1) {
      // error(localize("Spindle speed out of range."));
      // return;
    }
    if (spindleSpeed > 10000) {
      warning(localize("Spindle speed exceeds maximum value."));
    }
    
    if(isBroach){ //if this operation is the alignment op, have no spindle
      writeBlock("M19 S0");
      // if(isAlignmentOp){
      //   writeBlock("M19 Q0");
      // }else{
      //   writeBlock(
      //     mFormat.format(5)
      //   );
      // }
    }else if(isDispenser){
      if(isRefill){
        writeBlock("M19 S297 Q0");
      }
      
    }else{ //if this operation is not the alignment op, have a spindle speed
      writeBlock(
        sOutput.format(spindleSpeed), mFormat.format(tool.clockwise ? 3 : 4)
      );
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
    if (workOffset > 6) {
      error(localize("Work offset out of range."));
      return;
    } else {
      if (workOffset != currentWorkOffset) {
        writeBlock(gFormat.format(53 + workOffset)); // G54->G59
        currentWorkOffset = workOffset;
      }
    }
  }

  forceXYZ();

  if (forceMultiAxisIndexing || !is3D() || machineConfiguration.isMultiAxisConfiguration()) { // use 5-axis indexing for multi-axis mode
    // set working plane after datum shift

    if (currentSection.isMultiAxis()) {
      forceWorkPlane();
      cancelTransformation();
    } else {
      var abc = new Vector(0, 0, 0);
      if (useMultiAxisFeatures && !machineConfiguration.isMultiAxisConfiguration()) {
        // writeln("VECTOR")
        abc = currentSection.getGlobalInitialToolAxis(); // using vectors
      } else {
        // writeln("MACHINE ANGLES")
        abc = getWorkPlaneMachineABC(currentSection.workPlane);
      }
      setWorkPlane(abc);
    }
  } else { // pure 3D
    var remaining = currentSection.workPlane;
    if (!isSameDirection(remaining.forward, new Vector(0, 0, 1))) {
      error(localize("Tool orientation is not supported."));
      return;
    }
    setRotation(remaining);
  }
  if (g68RotationMode != 0 && (insertToolCall || gRotationModal.getCurrent() == 69)) {
    setProbingAngle();
  }
  // set coolant after we have positioned at Z
  setCoolant(tool.coolant);

  forceAny();

  if (currentSection.isMultiAxis()) {
    onCommand(COMMAND_UNLOCK_MULTI_AXIS);

    writeBlock(gFormat.format(69));
    writeBlock(mFormat.format(128)); // only after we are at initial position

    // turn
    var abc;
    var d = currentSection.getGlobalInitialToolAxis();
    var initialPosition = getFramePosition(currentSection.getInitialPosition());
    if (currentSection.isOptimizedForMachine()) {
      abc = currentSection.getInitialToolAxisABC();
      writeBlock(
        gMotionModal.format(0), gFormat.format(8.2),
        xOutput.format(initialPosition.x), yOutput.format(initialPosition.y), zOutput.format(initialPosition.z),
        aOutput.format(abc.x), bOutput.format(abc.y), cOutput.format(abc.z)
      );
    } else {
      gMotionModal.reset();
      writeBlock(
        gMotionModal.format(0), gFormat.format(8.2),
        xOutput.format(initialPosition.x), yOutput.format(initialPosition.y), zOutput.format(initialPosition.z),
        "I" + ijkFormat.format(d.x), "J" + ijkFormat.format(d.y), "K" + ijkFormat.format(d.z)
      );
    }
    writeBlock(gFormat.format(43.4));
    writeBlock(mFormat.format(200), "P" + (getProperty("preferPositiveTilt") ? 1 : 2)); // prefer positive/negative tilt
  } else {
    var initialPosition = getFramePosition(currentSection.getInitialPosition());
    if (!retracted && !insertToolCall) {
      if (getCurrentPosition().z < initialPosition.z) {
        writeBlock(gMotionModal.format(0), zOutput.format(initialPosition.z));
        machineSimulation({z:initialPosition.z});
      }
    }
  
    if (insertToolCall || retracted) {
      var lengthOffset = tool.lengthOffset;
      if (lengthOffset > 9999) {
        warning(localize("The length offset exceeds the maximum value."));
      }

      gMotionModal.reset();
      writeBlock(gPlaneModal.format(17));

      if (!machineConfiguration.isHeadConfiguration()) {
        writeBlock(
          gAbsIncModal.format(90),
          gMotionModal.format(0), xOutput.format(initialPosition.x), yOutput.format(initialPosition.y)
        );
        machineSimulation({x:initialPosition.x, y:initialPosition.y});
        if (!useMultiAxisFeatures || currentSection.isZOriented()) {
          writeBlock(gMotionModal.format(0), gFormat.format(43), zOutput.format(initialPosition.z), hFormat.format(lengthOffset));
        } else {
          writeBlock(gMotionModal.format(0), zOutput.format(initialPosition.z));
        }
        machineSimulation({z:initialPosition.z});
      } else {
        if (!useMultiAxisFeatures || currentSection.isZOriented()) {
          writeBlock(
            gAbsIncModal.format(90),
            gMotionModal.format(0),
            gFormat.format(43), xOutput.format(initialPosition.x),
            yOutput.format(initialPosition.y),
            zOutput.format(initialPosition.z), hFormat.format(lengthOffset)
          );
        } else {
          writeBlock(
            gAbsIncModal.format(90),
            gMotionModal.format(0),
            xOutput.format(initialPosition.x),
            yOutput.format(initialPosition.y),
            zOutput.format(initialPosition.z)
          );
        }
        machineSimulation({x:initialPosition.x, y:initialPosition.y, z:initialPosition.z});
      }
    } else {
      writeBlock(
        gAbsIncModal.format(90),
        gMotionModal.format(0),
        xOutput.format(initialPosition.x),
        yOutput.format(initialPosition.y)
      );
      machineSimulation({x:initialPosition.x, y:initialPosition.y});
    }
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

  edgeFeed.onSection(currentSection, tool);
  if (edgeFeed.isActive()) {
    activeMovements = undefined; // parametric feeds are not used with buffered edge feed moves
  }

  if (isProbeOperation()) {
    if (g68RotationMode != 0) {
      error(localize("You cannot probe while G68 Rotation is in effect."));
      return;
    }
    angularProbingMode = getAngularProbingMode();
    writeBlock(gFormat.format(65), "P" + 9832); // spin the probe on
  }

  // surface Inspection
  if (isInspectionOperation(currentSection) && (typeof inspectionProcessSectionStart == "function")) {
    inspectionProcessSectionStart();
  }

/*
  if (getProperty("smoothingTolerance") > 0) {
    writeBlock(gFormat.format(5.2), "P1", "Q" + xyzFormat.format(getProperty("smoothingTolerance")));
  }
*/
}

function onDwell(seconds) {
  edgeFeed.flush();
  if (seconds > 9999.999) {
    warning(localize("Dwelling time is out of range."));
  }
  seconds = clamp(0.001, seconds, 9999.999);
  writeBlock(gFormat.format(4), "P" + secFormat.format(seconds));
}

function onSpindleSpeed(spindleSpeed) {
  edgeFeed.flush();
  writeBlock(sOutput.format(spindleSpeed));
}

function onCycle() {
  edgeFeed.flush();
  writeBlock(gPlaneModal.format(17));
}

function getCommonCycle(x, y, z, r) {
  forceXYZ();
  if (getProperty("isnc")) {
    return [xOutput.format(x), yOutput.format(y),
      zOutput.format(z),
      "R" + xyzFormat.format(r)];
  } else {
    return [xOutput.format(x), yOutput.format(y),
      "Z" + xyzFormat.format(z),
      "R" + xyzFormat.format(r)];
  }
}

/** Convert approach to sign. */
function approach(value) {
  validate((value == "positive") || (value == "negative"), "Invalid approach.");
  return (value == "positive") ? 1 : -1;
}

function getRotationalAxis() {
  if (machineConfiguration.getAxisU().isEnabled() &&
      isSameDirection((machineConfiguration.getAxisU().getAxis()).getAbsolute(), new Vector(0, 0, 1)) &&
      machineConfiguration.getAxisU().isTable()) {
    return (machineConfiguration.getAxisU().getCoordinate());
  } else if (machineConfiguration.getAxisV().isEnabled() &&
      isSameDirection((machineConfiguration.getAxisV().getAxis()).getAbsolute(), new Vector(0, 0, 1)) &&
      machineConfiguration.getAxisV().isTable()) {
    return (machineConfiguration.getAxisV().getCoordinate());
  } else if (machineConfiguration.getAxisW().isEnabled() &&
      isSameDirection((machineConfiguration.getAxisW().getAxis()).getAbsolute(), new Vector(0, 0, 1)) &&
      machineConfiguration.getAxisW().isTable()) {
    return (machineConfiguration.getAxisW().getCoordinate());
  } else {
    return -1;
  }
}

/**
  Determine if angular probing is supported.
*/
var rotationalAxis = -1;
var isWCSProbing = false;

function getAngularProbingMode() {
  rotationalAxis = getRotationalAxis();
  isWCSProbing = (hasParameter("operation-strategy") && (getParameter("operation-strategy") == "probe"));
  if (rotationalAxis != -1) {
    return (ANGLE_PROBE_USE_CAXIS);
  } else if (machineConfiguration.getNumberOfAxes() < 5) {
    return (ANGLE_PROBE_USE_ROTATION);
  } else {
    return (ANGLE_PROBE_NOT_SUPPORTED);
  }
}

/**
  Output rotation offset based on angular probing cycle.
*/
function setProbingAngle() {
  if (((g68RotationMode == 1) || (g68RotationMode == 2)) && isWCSProbing) { // Rotate coordinate system for Angle Probing
    if (angularProbingMode == ANGLE_PROBE_USE_ROTATION) {
      gRotationModal.reset();
      gAbsIncModal.reset();
      var xCode = (g68RotationMode == 1) ? "X0" : "X[#185]";
      var yCode = (g68RotationMode == 1) ? "Y0" : "Y[#186]";
      writeBlock(gRotationModal.format(68), gAbsIncModal.format(90), xCode, yCode, "R[#144]");
    } else if (angularProbingMode == ANGLE_PROBE_USE_CAXIS) {
      var workOffset = probeOutputWorkOffset ? probeOutputWorkOffset : currentWorkOffset;
      if (workOffset > 6) {
        error(localize("Angle Probing only supports work offsets 1-6."));
        return;
      }
      var param = 5200 + workOffset * 20 + 5;
      writeBlock("#" + param + " = " + "[#" + param + " + #144]");
      g68RotationMode = 0;
    } else {
      error(localize("Angular Probing is not supported for this machine configuration."));
      return;
    }
  }
}

function protectedProbeMove(_cycle, x, y, z) {
  var _x = xOutput.format(x);
  var _y = yOutput.format(y);
  var _z = zOutput.format(z);
  if (_z && z >= getCurrentPosition().z) {
    writeBlock(gFormat.format(65), "P" + 9810, _z, getFeed(cycle.feedrate)); // protected positioning move
  }
  if (_x || _y) {
    writeBlock(gFormat.format(65), "P" + 9810, _x, _y, getFeed(highFeedrate)); // protected positioning move
  }
  if (_z && z < getCurrentPosition().z) {
    writeBlock(gFormat.format(65), "P" + 9810, _z, getFeed(cycle.feedrate)); // protected positioning move
  }
}

/**
  Null the probing angle when needed.
*/
function nullProbeAngle(force) {
  var cycleType = currentSection.getFirstCycle();
  if (g68RotationMode != 0) {
    writeBlock(gRotationModal.format(69));
  } else if (force && cycleType.indexOf("probing") != -1) {
    gRotationModal.reset();
    forceXYZ();
    writeBlock(gRotationModal.format(69));
  }
}

function onCyclePoint(x, y, z) {
  edgeFeed.flush();
  if (cycleType == "inspect") {
    if (typeof inspectionCycleInspect == "function") {
      inspectionCycleInspect(cycle, x, y, z);
      return;
    } else {
      cycleNotSupported();
    }
  }
  if (!isSameDirection(getRotation().forward, new Vector(0, 0, 1))) {
    expandCyclePoint(x, y, z);
    return;
  }
  var probeWorkOffsetCode;
  if (isProbeOperation()) {
    if (!useMultiAxisFeatures && !isSameDirection(currentSection.workPlane.forward, new Vector(0, 0, 1)) && (!cycle.probeMode || (cycle.probeMode == 0))) {
      error(localize("Updating WCS / work offset using probing is only supported by the CNC in the WCS frame."));
      return;
    }
    protectedProbeMove(cycle, x, y, z);

    var workOffset = probeOutputWorkOffset ? probeOutputWorkOffset : currentWorkOffset;
    if (workOffset > 99) {
      error(localize("Work offset is out of range."));
      return;
    } else if (workOffset > 6) {
      probeWorkOffsetCode = probe100Format.format(workOffset - 6 + 100);
    } else {
      probeWorkOffsetCode = workOffset + "."; // G54->G59
    }
  }

  if (isFirstCyclePoint() || isProbeOperation()) {
    if (!isProbeOperation()) {
      // return to initial Z which is clearance plane and set absolute mode
      repositionToCycleClearance(cycle, x, y, z);
    }
    // R is only used in G99 mode for BNC

    var F = cycle.feedrate;
    var P = !cycle.dwell ? 0 : clamp(1, cycle.dwell, 9999.999); // in seconds
    
    switch (cycleType) {
    case "drilling":
      if (getProperty("isnc")) {
        writeBlock(
          gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(81),
          getCommonCycle(x, y, z, cycle.retract),
          feedOutput.format(F)
        );
      } else { // BNC mode
        writeBlock(
          gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(81),
          getCommonCycle(x, y, cycle.clearance - cycle.bottom, zOutput.getCurrent() - cycle.retract),
          feedOutput.format(F)
        );
      }
      break;
    case "counter-boring":
      if (P > 0) {
        if (getProperty("isnc")) {
          writeBlock(
            gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(82),
            getCommonCycle(x, y, z, cycle.retract),
            "P" + secFormat.format(cycle.dwell), // not optional
            feedOutput.format(F)
          );
          // writeComment(cycle.dwell);
        } else { // BNC mode
          writeBlock(
            gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(82),
            getCommonCycle(x, y, cycle.clearance - cycle.bottom, zOutput.getCurrent() - cycle.retract),
            "P" + secFormat.format(P), // not optional
            feedOutput.format(F)
          );
        }
      } else {
        if (getProperty("isnc")) {
          writeBlock(
            gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(81),
            getCommonCycle(x, y, z, cycle.retract),
            feedOutput.format(F)
          );
        } else { // BNC mode
          writeBlock(
            gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(81),
            getCommonCycle(x, y, cycle.clearance - cycle.bottom, zOutput.getCurrent() - cycle.retract),
            feedOutput.format(F)
          );
        }
      }
      break;
    case "chip-breaking":
      if ((cycle.accumulatedDepth < (2*cycle.depth)) || (P > 0)) {
        expandCyclePoint(x, y, z);
      } else {
        if (getProperty("isnc")) {
          writeBlock(
            gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(73),
            getCommonCycle(x, y, z, cycle.retract),
            "Q" + xyzFormat.format(cycle.incrementalDepth),
            feedOutput.format(F)
          );
        } else { // BNC mode
          writeBlock(
            gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(73),
            getCommonCycle(x, y, cycle.clearance - cycle.bottom, zOutput.getCurrent() - cycle.retract),
            "Q" + xyzFormat.format(cycle.incrementalDepth),
            feedOutput.format(F)
          );
        }
      }
      break;
    case "deep-drilling":
      if (P > 0) {
        expandCyclePoint(x, y, z);
      } else {
        if (getProperty("isnc")) {
          writeBlock(
            gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(83),
            getCommonCycle(x, y, z, cycle.retract),
            "Q" + xyzFormat.format(cycle.incrementalDepth),
            feedOutput.format(F)
          );
        } else { // BNC mode
          writeBlock(
            gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(83),
            xOutput.format(x),
            yOutput.format(y),
            "Z" + xyzFormat.format(cycle.clearance - cycle.bottom),
            "Z" + xyzFormat.format(cycle.incrementalDepth), // first peck
            conditional((cycle.minimumIncrementalDepth != undefined) && (cycle.minimumIncrementalDepth < cycle.incrementalDepth), "Z" + xyzFormat.format(cycle.minimumIncrementalDepth)), // remaining pecks
            "R" + xyzFormat.format(zOutput.getCurrent() - cycle.retract),
            feedOutput.format(F)
          );
        }
      }
      break;
    case "tapping":
      if (true || !F) {
        F = tool.getTappingFeedrate();
      }
      if (getProperty("isnc")) {
        writeBlock(mFormat.format(29)); // rigid
        writeBlock(
          gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format((tool.type == TOOL_TAP_LEFT_HAND) ? 74 : 84),
          getCommonCycle(x, y, z, cycle.retract),
          "P" + secFormat.format(P), // not optional
          feedOutput.format(F)
        );
      } else { // BNC mode
        if (tool.type != TOOL_TAP_LEFT_HAND) { // right hand
          writeBlock(mFormat.format(3)); // cw
          writeBlock(
            gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(88), // rigid
            xOutput.format(x),
            yOutput.format(y),
            "Z" + xyzFormat.format(cycle.clearance - cycle.bottom),
            //"Z" + xyzFormat.format(cycle.incrementalDepth),
            "R" + xyzFormat.format(zOutput.getCurrent() - cycle.retract),
            "P" + secFormat.format(P), // not optional
            feedOutput.format(F)
          );
          if (!tool.clockwise) {
            writeBlock(mFormat.format(tool.clockwise ? 3 : 4));
          }
        } else { // left hand
          // warning: not rigid

          writeBlock(mFormat.format((tool.type == TOOL_TAP_LEFT_HAND) ? 4 : 3));
          writeBlock(
            gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(84),
            getCommonCycle(x, y, cycle.clearance - cycle.bottom, zOutput.getCurrent() - cycle.retract),
            feedOutput.format(F)
          );
          if ((tool.type == TOOL_TAP_LEFT_HAND) != !tool.clockwise) {
            writeBlock(mFormat.format(tool.clockwise ? 3 : 4));
          }
        }
      }
      break;
    case "left-tapping":
      if (true || !F) {
        F = tool.getTappingFeedrate();
      }
      if (getProperty("isnc")) {
        writeBlock(mFormat.format(29)); // rigid
        writeBlock(
          gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(74),
          getCommonCycle(x, y, z, cycle.retract),
          "P" + secFormat.format(P), // not optional
          feedOutput.format(F)
        );
      } else { // BNC mode
        // warning: not rigid
        writeBlock(mFormat.format(4)); // ccw
        writeBlock(
          gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(84),
          getCommonCycle(x, y, cycle.clearance - cycle.bottom, zOutput.getCurrent() - cycle.retract),
          feedOutput.format(F)
        );
        if (tool.clockwise) {
          writeBlock(mFormat.format(tool.clockwise ? 3 : 4));
        }
      }
      break;
    case "right-tapping":
      if (true || !F) {
        F = tool.getTappingFeedrate();
      }
      if (getProperty("isnc")) {
        writeBlock(mFormat.format(29)); // rigid
        writeBlock(
          gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(84),
          getCommonCycle(x, y, z, cycle.retract),
          "P" + secFormat.format(P), // not optional
          feedOutput.format(F)
        );
      } else { // BNC mode
        writeBlock(mFormat.format(3)); // cw
        writeBlock(
          gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(88), // rigid
          xOutput.format(x),
          yOutput.format(y),
          "Z" + xyzFormat.format(cycle.clearance - cycle.bottom),
          "R" + xyzFormat.format(zOutput.getCurrent() - cycle.retract),
          "P" + secFormat.format(P), // not optional
          feedOutput.format(F)
        );
        if (!tool.clockwise) {
          writeBlock(mFormat.format(tool.clockwise ? 3 : 4));
        }
      }
      break;
    case "tapping-with-chip-breaking":
    case "left-tapping-with-chip-breaking":
    case "right-tapping-with-chip-breaking":
      if (cycle.accumulatedDepth < cycle.depth) {
        error(localize("Accumulated pecking depth is not supported for canned tapping cycles with chip breaking."));
        return;
      }
      if (true || !F) {
        F = tool.getTappingFeedrate();
      }
      if (getProperty("isnc")) {
        forceXYZ();
        writeBlock(mFormat.format(29)); // rigid
        writeBlock(
          gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format((tool.type == TOOL_TAP_LEFT_HAND) ? 84.3 : 84.2),
          // getCommonCycle(x, y, z, cycle.retract),
          xOutput.format(x),
          yOutput.format(y),
          "Z" + xyzFormat.format(z),
          "Z" + xyzFormat.format(cycle.incrementalDepth),
          "R" + xyzFormat.format(cycle.retract),
          "P" + secFormat.format(P), // not optional
          conditional(cycle.minimumIncrementalDepth < cycle.depth, "Q" + xyzFormat.format(cycle.minimumIncrementalDepth)), // optional
          feedOutput.format(F)
        );
        zOutput.reset();
      } else { // BNC mode
        if (tool.type != TOOL_TAP_LEFT_HAND) { // right hand
          writeBlock(mFormat.format(3)); // cw
          writeBlock(
            gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(88), // rigid
            xOutput.format(x),
            yOutput.format(y),
            "Z" + xyzFormat.format(cycle.clearance - cycle.bottom),
            "Z" + xyzFormat.format(cycle.incrementalDepth),
            "R" + xyzFormat.format(zOutput.getCurrent() - cycle.retract),
            "P" + secFormat.format(P), // not optional
            feedOutput.format(F)
          );
          if (!tool.clockwise) {
            writeBlock(mFormat.format(tool.clockwise ? 3 : 4));
          }
        } else {
          error(localize("Left-tapping with chip breaking is not supported."));
        }
      }
      break;
    case "fine-boring":
      //Using G76 cycle on the hurco, there is no way to orient the spindle to an angle.
      //A workaround to use the spindle shift orientation value in fusion is to shift in
      //both X and Y, using the I and J words. The I and J values are calculated using
      //trig of the angle and shift distance.
      var Ival = cycle.shift * Math.cos(cycle.shiftOrientation);
      var Jval = cycle.shift * Math.sin(cycle.shiftOrientation);
      if (getProperty("isnc")) {
        writeBlock(
          gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(76),
          getCommonCycle(x, y, z, cycle.retract),
          "P" + secFormat.format(P), // not optional
          // "Q" + xyzFormat.format(cycle.shift),
          //Q is shift distance in X positive. For X and Y shift, I and J values are needed
          "I" + xyzFormat.format(Ival),
          "J" + xyzFormat.format(Jval),
          feedOutput.format(F)
        );
      } else { // BNC mode
        writeBlock(
          gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(76),
          getCommonCycle(x, y, cycle.clearance - cycle.bottom, zOutput.getCurrent() - cycle.retract),
          "P" + secFormat.format(P), // not optional
          "Q" + xyzFormat.format(cycle.shift),
          feedOutput.format(F)
        );
      }
      break;
    case "back-boring":
      if (!getProperty("isnc")) {
        error(localize("Back boring is not supported."));
      }
      var dx = (gPlaneModal.getCurrent() == 19) ? cycle.backBoreDistance : 0;
      var dy = (gPlaneModal.getCurrent() == 18) ? cycle.backBoreDistance : 0;
      var dz = (gPlaneModal.getCurrent() == 17) ? cycle.backBoreDistance : 0;
      writeBlock(
        gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(87),
        getCommonCycle(x - dx, y - dy, z - dz, cycle.bottom),
        "Q" + xyzFormat.format(cycle.shift),
        "P" + secFormat.format(P), // not optional
        feedOutput.format(F)
      );
      break;
    case "reaming":
      if (getProperty("isnc")) {
        if(tool.comment==="broach"){
          writeComment("Broaching cycle");
          //feed tool into Top Height position
          writeBlock(gMotionModal.format(1), zOutput.format(cycle.retract), feedOutput.format(F));
          //Optional stop
          writeBlock(mFormat.format(1));
          //Start spindle
          writeBlock(sOutput.format(spindleSpeed), mFormat.format(tool.clockwise ? 3 : 4));
          //Feed to Hole Bottom position
          writeBlock(gMotionModal.format(1), zOutput.format(cycle.bottom), feedOutput.format(F));
          //Feed to Top Height position
          writeBlock(gMotionModal.format(1), zOutput.format(cycle.retract), feedOutput.format(F));
          //stop spindle
          writeBlock("M19 Q0");
          
        }else{
          writeBlock(
            gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(85),
            getCommonCycle(x, y, z, cycle.retract),
            feedOutput.format(F)
          );
        }
      } else { // BNC mode
        writeBlock(
          gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(85),
          getCommonCycle(x, y, cycle.clearance - cycle.bottom, zOutput.getCurrent() - cycle.retract),
          feedOutput.format(F)
        );
      }
      break;
    case "stop-boring":
      if ((P > 0) || !getProperty("isnc")) {
        expandCyclePoint(x, y, z);
      } else {
        writeBlock(
          gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(86),
          getCommonCycle(x, y, z, cycle.retract),
          feedOutput.format(F)
        );
      }
      break;
    case "manual-boring":
      if (!getProperty("isnc")) {
        error(localize("Manual boring is not supported."));
      }
      writeBlock(
        gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(88),
        getCommonCycle(x, y, z, cycle.retract),
        "P" + secFormat.format(P), // not optional
        feedOutput.format(F)
      );
      break;
    case "boring":
      if (getProperty("isnc")) {
        writeBlock(
          gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(89),
          getCommonCycle(x, y, z, cycle.retract),
          "P" + secFormat.format(P), // not optional
          feedOutput.format(F)
        );
      } else { // BNC
        writeBlock(
          gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(89),
          getCommonCycle(x, y, cycle.clearance - cycle.bottom, zOutput.getCurrent() - cycle.retract),
          "P" + secFormat.format(P), // not optional
          feedOutput.format(F)
        );
      }
      break;
    case "probing-x":
      protectedProbeMove(cycle, x, y, z - cycle.depth);
      writeBlock(
        gFormat.format(65), "P" + 9811,
        "X" + xyzFormat.format(x + approach(cycle.approach1) * (cycle.probeClearance + tool.diameter / 2)),
        "Q" + xyzFormat.format(cycle.probeOvertravel),
        getProbingArguments(cycle, probeWorkOffsetCode)
      );
      break;
    case "probing-y":
      protectedProbeMove(cycle, x, y, z - cycle.depth);
      writeBlock(
        gFormat.format(65), "P" + 9811,
        "Y" + xyzFormat.format(y + approach(cycle.approach1) * (cycle.probeClearance + tool.diameter / 2)),
        "Q" + xyzFormat.format(cycle.probeOvertravel),
        getProbingArguments(cycle, probeWorkOffsetCode)
      );
      break;
    case "probing-z":
      protectedProbeMove(cycle, x, y, Math.min(z - cycle.depth + cycle.probeClearance, cycle.retract));
      writeBlock(
        gFormat.format(65), "P" + 9811,
        "Z" + xyzFormat.format(z - cycle.depth),
        "Q" + xyzFormat.format(cycle.probeOvertravel),
        getProbingArguments(cycle, probeWorkOffsetCode)
      );
      break;
    case "probing-x-wall":
      protectedProbeMove(cycle, x, y, z);
      writeBlock(
        gFormat.format(65), "P" + 9812,
        "X" + xyzFormat.format(cycle.width1),
        zOutput.format(z - cycle.depth),
        "Q" + xyzFormat.format(cycle.probeOvertravel),
        "R" + xyzFormat.format(cycle.probeClearance),
        getProbingArguments(cycle, probeWorkOffsetCode)
      );
      break;
    case "probing-y-wall":
      protectedProbeMove(cycle, x, y, z);
      writeBlock(
        gFormat.format(65), "P" + 9812,
        "Y" + xyzFormat.format(cycle.width1),
        zOutput.format(z - cycle.depth),
        "Q" + xyzFormat.format(cycle.probeOvertravel),
        "R" + xyzFormat.format(cycle.probeClearance),
        getProbingArguments(cycle, probeWorkOffsetCode)
      );
      break;
    case "probing-x-channel":
      protectedProbeMove(cycle, x, y, z - cycle.depth);
      writeBlock(
        gFormat.format(65), "P" + 9812,
        "X" + xyzFormat.format(cycle.width1),
        "Q" + xyzFormat.format(cycle.probeOvertravel),
        // not required "R" + xyzFormat.format(cycle.probeClearance),
        getProbingArguments(cycle, probeWorkOffsetCode)
      );
      break;
    case "probing-x-channel-with-island":
      protectedProbeMove(cycle, x, y, z);
      writeBlock(
        gFormat.format(65), "P" + 9812,
        "X" + xyzFormat.format(cycle.width1),
        zOutput.format(z - cycle.depth),
        "Q" + xyzFormat.format(cycle.probeOvertravel),
        "R" + xyzFormat.format(-cycle.probeClearance),
        getProbingArguments(cycle, probeWorkOffsetCode)
      );
      break;
    case "probing-y-channel":
      protectedProbeMove(cycle, x, y, z - cycle.depth);
      writeBlock(
        gFormat.format(65), "P" + 9812,
        "Y" + xyzFormat.format(cycle.width1),
        "Q" + xyzFormat.format(cycle.probeOvertravel),
        // not required "R" + xyzFormat.format(cycle.probeClearance),
        getProbingArguments(cycle, probeWorkOffsetCode)
      );
      break;
    case "probing-y-channel-with-island":
      protectedProbeMove(cycle, x, y, z);
      writeBlock(
        gFormat.format(65), "P" + 9812,
        "Y" + xyzFormat.format(cycle.width1),
        zOutput.format(z - cycle.depth),
        "Q" + xyzFormat.format(cycle.probeOvertravel),
        "R" + xyzFormat.format(-cycle.probeClearance),
        getProbingArguments(cycle, probeWorkOffsetCode)
      );
      break;
    case "probing-xy-circular-boss":
      protectedProbeMove(cycle, x, y, z);
      writeBlock(
        gFormat.format(65), "P" + 9814,
        "D" + xyzFormat.format(cycle.width1),
        "Z" + xyzFormat.format(z - cycle.depth),
        "Q" + xyzFormat.format(cycle.probeOvertravel),
        "R" + xyzFormat.format(cycle.probeClearance),
        getProbingArguments(cycle, probeWorkOffsetCode)
      );
      break;
    case "probing-xy-circular-partial-boss":
      protectedProbeMove(cycle, x, y, z);
      writeBlock(
        gFormat.format(65), "P" + 9823,
        "A" + xyzFormat.format(cycle.partialCircleAngleA),
        "B" + xyzFormat.format(cycle.partialCircleAngleB),
        "C" + xyzFormat.format(cycle.partialCircleAngleC),
        "D" + xyzFormat.format(cycle.width1),
        "Z" + xyzFormat.format(z - cycle.depth),
        "Q" + xyzFormat.format(cycle.probeOvertravel),
        "R" + xyzFormat.format(cycle.probeClearance),
        getProbingArguments(cycle, probeWorkOffsetCode)
      );
      break;
    case "probing-xy-circular-hole":
      protectedProbeMove(cycle, x, y, z - cycle.depth);
      writeBlock(
        gFormat.format(65), "P" + 9814,
        "D" + xyzFormat.format(cycle.width1),
        "Q" + xyzFormat.format(cycle.probeOvertravel),
        // not required "R" + xyzFormat.format(cycle.probeClearance),
        getProbingArguments(cycle, probeWorkOffsetCode)
      );
      break;
    case "probing-xy-circular-partial-hole":
      protectedProbeMove(cycle, x, y, z - cycle.depth);
      writeBlock(
        gFormat.format(65), "P" + 9823,
        "A" + xyzFormat.format(cycle.partialCircleAngleA),
        "B" + xyzFormat.format(cycle.partialCircleAngleB),
        "C" + xyzFormat.format(cycle.partialCircleAngleC),
        "D" + xyzFormat.format(cycle.width1),
        "Q" + xyzFormat.format(cycle.probeOvertravel),
        getProbingArguments(cycle, probeWorkOffsetCode)
      );
      break;
    case "probing-xy-circular-hole-with-island":
      protectedProbeMove(cycle, x, y, z);
      writeBlock(
        gFormat.format(65), "P" + 9814,
        "Z" + xyzFormat.format(z - cycle.depth),
        "D" + xyzFormat.format(cycle.width1),
        "Q" + xyzFormat.format(cycle.probeOvertravel),
        "R" + xyzFormat.format(-cycle.probeClearance),
        getProbingArguments(cycle, probeWorkOffsetCode)
      );
      break;
    case "probing-xy-circular-partial-hole-with-island":
      protectedProbeMove(cycle, x, y, z);
      writeBlock(
        gFormat.format(65), "P" + 9823,
        "Z" + xyzFormat.format(z - cycle.depth),
        "A" + xyzFormat.format(cycle.partialCircleAngleA),
        "B" + xyzFormat.format(cycle.partialCircleAngleB),
        "C" + xyzFormat.format(cycle.partialCircleAngleC),
        "D" + xyzFormat.format(cycle.width1),
        "Q" + xyzFormat.format(cycle.probeOvertravel),
        "R" + xyzFormat.format(-cycle.probeClearance),
        getProbingArguments(cycle, probeWorkOffsetCode)
      );
      break;
    case "probing-xy-rectangular-hole":
      protectedProbeMove(cycle, x, y, z - cycle.depth);
      writeBlock(
        gFormat.format(65), "P" + 9812,
        "X" + xyzFormat.format(cycle.width1),
        "Q" + xyzFormat.format(cycle.probeOvertravel),
        // not required "R" + xyzFormat.format(-cycle.probeClearance),
        getProbingArguments(cycle, probeWorkOffsetCode)
      );
      writeBlock(
        gFormat.format(65), "P" + 9812,
        "Y" + xyzFormat.format(cycle.width2),
        "Q" + xyzFormat.format(cycle.probeOvertravel),
        // not required "R" + xyzFormat.format(-cycle.probeClearance),
        getProbingArguments(cycle, probeWorkOffsetCode)
      );
      break;
    case "probing-xy-rectangular-boss":
      protectedProbeMove(cycle, x, y, z);
      writeBlock(
        gFormat.format(65), "P" + 9812,
        "Z" + xyzFormat.format(z - cycle.depth),
        "X" + xyzFormat.format(cycle.width1),
        "R" + xyzFormat.format(cycle.probeClearance),
        "Q" + xyzFormat.format(cycle.probeOvertravel),
        getProbingArguments(cycle, probeWorkOffsetCode)
      );
      writeBlock(
        gFormat.format(65), "P" + 9812,
        "Z" + xyzFormat.format(z - cycle.depth),
        "Y" + xyzFormat.format(cycle.width2),
        "R" + xyzFormat.format(cycle.probeClearance),
        "Q" + xyzFormat.format(cycle.probeOvertravel),
        getProbingArguments(cycle, probeWorkOffsetCode)
      );
      break;
    case "probing-xy-rectangular-hole-with-island":
      protectedProbeMove(cycle, x, y, z);
      writeBlock(
        gFormat.format(65), "P" + 9812,
        "Z" + xyzFormat.format(z - cycle.depth),
        "X" + xyzFormat.format(cycle.width1),
        "Q" + xyzFormat.format(cycle.probeOvertravel),
        "R" + xyzFormat.format(-cycle.probeClearance),
        getProbingArguments(cycle, probeWorkOffsetCode)
      );
      writeBlock(
        gFormat.format(65), "P" + 9812,
        "Z" + xyzFormat.format(z - cycle.depth),
        "Y" + xyzFormat.format(cycle.width2),
        "Q" + xyzFormat.format(cycle.probeOvertravel),
        "R" + xyzFormat.format(-cycle.probeClearance),
        getProbingArguments(cycle, probeWorkOffsetCode)
      );
      break;
  
    case "probing-xy-inner-corner":
      var cornerX = x + approach(cycle.approach1) * (cycle.probeClearance + tool.diameter / 2);
      var cornerY = y + approach(cycle.approach2) * (cycle.probeClearance + tool.diameter / 2);
      var cornerI = 0;
      var cornerJ = 0;
      if (cycle.probeSpacing !== undefined) {
        cornerI = cycle.probeSpacing;
        cornerJ = cycle.probeSpacing;
      }
      if ((cornerI != 0) && (cornerJ != 0)) {
        g68RotationMode = 2;
      }
      protectedProbeMove(cycle, x, y, z - cycle.depth);
      writeBlock(
        gFormat.format(65), "P" + 9815, xOutput.format(cornerX), yOutput.format(cornerY),
        conditional(cornerI != 0, "I" + xyzFormat.format(cornerI)),
        conditional(cornerJ != 0, "J" + xyzFormat.format(cornerJ)),
        "Q" + xyzFormat.format(cycle.probeOvertravel),
        conditional((g68RotationMode == 0) || (angularProbingMode == ANGLE_PROBE_USE_CAXIS), getProbingArguments(cycle, probeWorkOffsetCode))
      );
      break;
    case "probing-xy-outer-corner":
      var cornerX = x + approach(cycle.approach1) * (cycle.probeClearance + tool.diameter / 2);
      var cornerY = y + approach(cycle.approach2) * (cycle.probeClearance + tool.diameter / 2);
      var cornerI = 0;
      var cornerJ = 0;
      if (cycle.probeSpacing !== undefined) {
        cornerI = cycle.probeSpacing;
        cornerJ = cycle.probeSpacing;
      }
      if ((cornerI != 0) && (cornerJ != 0)) {
        g68RotationMode = 2;
      }
      protectedProbeMove(cycle, x, y, z - cycle.depth);
      writeBlock(
        gFormat.format(65), "P" + 9816, xOutput.format(cornerX), yOutput.format(cornerY),
        conditional(cornerI != 0, "I" + xyzFormat.format(cornerI)),
        conditional(cornerJ != 0, "J" + xyzFormat.format(cornerJ)),
        "Q" + xyzFormat.format(cycle.probeOvertravel),
        conditional((g68RotationMode == 0) || (angularProbingMode == ANGLE_PROBE_USE_CAXIS), getProbingArguments(cycle, probeWorkOffsetCode))
      );
      break;
    case "probing-x-plane-angle":
      protectedProbeMove(cycle, x, y, z - cycle.depth);
      writeBlock(
        gFormat.format(65), "P" + 9843,
        "X" + xyzFormat.format(x + approach(cycle.approach1) * (cycle.probeClearance + tool.diameter / 2)),
        "D" + xyzFormat.format(cycle.probeSpacing),
        "Q" + xyzFormat.format(cycle.probeOvertravel),
        "A" + xyzFormat.format(cycle.nominalAngle != undefined ? cycle.nominalAngle : 90),
        getProbingArguments(cycle, false)
      );
      g68RotationMode = 1;
      break;
    case "probing-y-plane-angle":
      protectedProbeMove(cycle, x, y, z - cycle.depth);
      writeBlock(
        gFormat.format(65), "P" + 9843,
        "Y" + xyzFormat.format(y + approach(cycle.approach1) * (cycle.probeClearance + tool.diameter / 2)),
        "D" + xyzFormat.format(cycle.probeSpacing),
        "Q" + xyzFormat.format(cycle.probeOvertravel),
        "A" + xyzFormat.format(cycle.nominalAngle != undefined ? cycle.nominalAngle : 0),
        getProbingArguments(cycle, false)
      );
      g68RotationMode = 1;
      break;
    case "probing-xy-pcd-hole":
      protectedProbeMove(cycle, x, y, z);
      writeBlock(
        gFormat.format(65), "P" + 9819,
        "A" + xyzFormat.format(cycle.pcdStartingAngle),
        "B" + xyzFormat.format(cycle.numberOfSubfeatures),
        "C" + xyzFormat.format(cycle.widthPCD),
        "D" + xyzFormat.format(cycle.widthFeature),
        "K" + xyzFormat.format(z - cycle.depth),
        "Q" + xyzFormat.format(cycle.probeOvertravel),
        getProbingArguments(cycle, false)
      );
      if (cycle.updateToolWear) {
        error(localize("Update tool action is not supported with this cycle"));
        return;
      }
      break;
    case "probing-xy-pcd-boss":
      protectedProbeMove(cycle, x, y, z);
      writeBlock(
        gFormat.format(65), "P" + 9819,
        "A" + xyzFormat.format(cycle.pcdStartingAngle),
        "B" + xyzFormat.format(cycle.numberOfSubfeatures),
        "C" + xyzFormat.format(cycle.widthPCD),
        "D" + xyzFormat.format(cycle.widthFeature),
        "Z" + xyzFormat.format(z - cycle.depth),
        "Q" + xyzFormat.format(cycle.probeOvertravel),
        "R" + xyzFormat.format(cycle.probeClearance),
        getProbingArguments(cycle, false)
      );
      if (cycle.updateToolWear) {
        error(localize("Update tool action is not supported with this cycle"));
        return;
      }
      break;
      case "gun-drilling":
        writeComment("gun drilling");
        
          // if(liveTool){
          //   //fill in for gun drilling cycle using live tools
        var millx = x;
        var milly = y;
        var millz = z;
      // }else if(latheTool && !liveTool){
        //Expanded cycle
        writeBlock(gMotionModal.format(0), xOutput.format(millx), yOutput.format(milly));
        writeBlock(gMotionModal.format(0), zOutput.format(cycle.retract));
        if(cycle.stopSpindle==1){
          onCommand(COMMAND_STOP_SPINDLE);
        }else{
          writeBlock(mFormat.format(3),sOutput.format(cycle.positioningSpindleSpeed));
        }
        writeComment(cycle.startingDepth);
        writeComment(cycle.stock);
        writeBlock(gMotionModal.format(1), xOutput.format(millx), yOutput.format(milly), zOutput.format(cycle.stock-cycle.startingDepth), feedOutput.format(cycle.positioningFeedrate));
        writeBlock(mFormat.format(1));
        if(tool.coolant)writeBlock(mFormat.format(8));
        writeBlock(mFormat.format(3),sOutput.format(tool.spindleRPM));
        // broachingTool = true;
        var broachRev = getProperty("broachReversal");
        // writeComment("broach rev: " + broachRev);
        if(isBroach && broachRev>0){
          if(isBroach){
            var broachStart = cycle.stock-cycle.startingDepth;
            var broachingDist = broachStart-(cycle.bottom);
            var reversalSteps = 0;
            var remainderDist = 0;
            var cwBroaching = true;

            if(broachingDist>broachRev){
              reversalSteps = Math.floor(broachingDist/broachRev);
              remainderDist = broachingDist - (broachRev * reversalSteps);
              writeComment(reversalSteps);
              for( i=0;i<=reversalSteps;i++){
                writeBlock(gMotionModal.format(1), xOutput.format(millx), yOutput.format(milly), zOutput.format(broachStart-(i*broachRev)), feedOutput.format(cycle.positioningFeedrate));
                if(cwBroaching&&i){ //conditional to reverse spindle back and forth
                  cwBroaching = false;
                  writeBlock(mFormat.format(4),sOutput.format(tool.spindleRPM));
                }else if(i){
                  cwBroaching = true;
                  writeBlock(mFormat.format(3),sOutput.format(tool.spindleRPM));
                }
              }
              writeBlock(gMotionModal.format(1), xOutput.format(millx), yOutput.format(milly), zOutput.format(cycle.bottom), feedOutput.format(cycle.positioningFeedrate));
            }else{
              writeBlock(gMotionModal.format(1), xOutput.format(millx), yOutput.format(milly), zOutput.format(cycle.bottom), feedOutput.format(cycle.positioningFeedrate));
            }
            writeBlock(gMotionModal.format(1), xOutput.format(millx), yOutput.format(milly), zOutput.format(cycle.startingDepth+cycle.stock), feedOutput.format(cycle.positioningFeedrate));
            onCommand(COMMAND_STOP_SPINDLE);
            writeBlock(gMotionModal.format(1), xOutput.format(millx), yOutput.format(milly), zOutput.format(cycle.retract), feedOutput.format(cycle.positioningFeedrate));
            
          }
        }else{
              writeBlock(gMotionModal.format(1), xOutput.format(millx), yOutput.format(milly), zOutput.format(cycle.bottom), feedOutput.format(cycle.feedrate));
              if(cycle.dwell)onDwell(cycle.dwell);
              writeBlock(gMotionModal.format(1), xOutput.format(millx), yOutput.format(milly), zOutput.format(cycle.retract), feedOutput.format(cycle.retractFeedrate));
        }
        break;
    default:
      expandCyclePoint(x, y, z);
    }
  } else {
    if (cycleExpanded) {
      expandCyclePoint(x, y, z);
    } else {
      var _x = xOutput.format(x);
      var _y = yOutput.format(y);
      if (!_x && !_y) {
        xOutput.reset(); // at least one axis is required
        _x = xOutput.format(x);
      }
      writeBlock(_x, _y);
    }
  }
}

function getProbingArguments(cycle, probeWorkOffsetCode) {
  var probeWCS = hasParameter("operation-strategy") && (getParameter("operation-strategy") == "probe");
  return [
    (cycle.angleAskewAction == "stop-message" ? "B" + xyzFormat.format(cycle.toleranceAngle ? cycle.toleranceAngle : 0) : undefined),
    ((cycle.updateToolWear && cycle.toolWearErrorCorrection < 100) ? "F" + xyzFormat.format(cycle.toolWearErrorCorrection ? cycle.toolWearErrorCorrection / 100 : 100) : undefined),
    (cycle.wrongSizeAction == "stop-message" ? "H" + xyzFormat.format(cycle.toleranceSize ? cycle.toleranceSize : 0) : undefined),
    (cycle.outOfPositionAction == "stop-message" ? "M" + xyzFormat.format(cycle.tolerancePosition ? cycle.tolerancePosition : 0) : undefined),
    ((cycle.updateToolWear && cycleType == "probing-z") ? "T" + xyzFormat.format(cycle.toolLengthOffset) : undefined),
    ((cycle.updateToolWear && cycleType !== "probing-z") ? "T" + xyzFormat.format(cycle.toolDiameterOffset) : undefined),
    (cycle.updateToolWear ? "V" + xyzFormat.format(cycle.toolWearUpdateThreshold ? cycle.toolWearUpdateThreshold : 0) : undefined),
    (cycle.printResults ? "W" + xyzFormat.format(1 + cycle.incrementComponent) : undefined), // 1 for advance feature, 2 for reset feature count and advance component number. first reported result in a program should use W2.
    conditional(probeWorkOffsetCode && probeWCS, "S" + probeWorkOffsetCode)
  ];
}

function onCycleEnd() {
  edgeFeed.flush();
  if (isProbeOperation()) {
    zOutput.reset();
    gMotionModal.reset();
    writeBlock(gFormat.format(65), "P" + 9810, zOutput.format(cycle.retract)); // protected retract move
  } else {
    if (!cycleExpanded) {
      writeBlock(gCycleModal.format(80));
      zOutput.reset();
    }
  }
}

var pendingRadiusCompensation = -1;

function onRadiusCompensation() {
  edgeFeed.flush();
  pendingRadiusCompensation = radiusCompensation;
}

var forceG0 = true; // add this line
function onRapid(_x, _y, _z) {
  edgeFeed.flush();
  var x = xOutput.format(_x);
  var y = yOutput.format(_y);
  var z = zOutput.format(_z);
  if (x || y || z) {
    if (pendingRadiusCompensation >= 0) {
      error(localize("Radius compensation mode cannot be changed at rapid traversal."));
      return;
    }
    if (getProperty("isnc") && (((x ? 1 : 0) + (y ? 1 : 0) + (z ? 1 : 0)) > 1) && !forceG0) {
      // axes are not synchronized
      writeBlock(gMotionModal.format(1), x, y, z, feedOutput.format(highFeedrate));
    } else {
      writeBlock(gMotionModal.format(0), x, y, z);
      forceFeed();
    }
  }
}

function onLinear(_x, _y, _z, feed) {
  if ((pendingRadiusCompensation < 0) && edgeFeed.onLinear(_x, _y, _z, feed)) {
    return; // buffered by the edge feed module, written later through writeLinear()
  }
  edgeFeed.flush();
  writeLinear(_x, _y, _z, feed);
}

/** Writes a linear move. Must not use getCurrentPosition(), as the edge feed module calls it one move late. */
function writeLinear(_x, _y, _z, feed) {
  if (pendingRadiusCompensation >= 0) {
    // ensure that we end at desired position when compensation is turned off
    xOutput.reset();
    yOutput.reset();
  }
  var x = xOutput.format(_x);
  var y = yOutput.format(_y);
  var z = zOutput.format(_z);
  var f = getFeed(feed);
  if (x || y || z) {
    if (pendingRadiusCompensation >= 0) {
      pendingRadiusCompensation = -1;
      var d = tool.diameterOffset;
      if (d > 200) {
        warning(localize("The diameter offset exceeds the maximum value."));
      }
      writeBlock(gPlaneModal.format(17));
      switch (radiusCompensation) {
      case RADIUS_COMPENSATION_LEFT:
        dOutput.reset();
        writeBlock(gMotionModal.format(1), gFormat.format(41), x, y, z, dOutput.format(d), f);
        break;
      case RADIUS_COMPENSATION_RIGHT:
        dOutput.reset();
        writeBlock(gMotionModal.format(1), gFormat.format(42), x, y, z, dOutput.format(d), f);
        break;
      default:
        writeBlock(gMotionModal.format(1), gFormat.format(40), x, y, z, f);
      }
    } else {
      writeBlock(gMotionModal.format(1), x, y, z, f);
    }
  } else if (f) {
    if (getNextRecord().isMotion()) { // try not to output feed without motion
      forceFeed(); // force feed on next line
    } else {
      writeBlock(gMotionModal.format(1), f);
    }
  }
}

function onRapid5D(_x, _y, _z, _a, _b, _c) {
  edgeFeed.flush();
  if (pendingRadiusCompensation >= 0) {
    error(localize("Radius compensation mode cannot be changed at rapid traversal."));
    return;
  }
  if (currentSection.isOptimizedForMachine()) {
    var x = xOutput.format(_x);
    var y = yOutput.format(_y);
    var z = zOutput.format(_z);
    var a = aOutput.format(_a);
    var b = bOutput.format(_b);
    var c = cOutput.format(_c);
    if (getProperty("isnc")) {
      // axes are not synchronized
      writeBlock(gMotionModal.format(1), x, y, z, a, b, c, feedOutput.format(highFeedrate));
    } else {
      writeBlock(gMotionModal.format(0), x, y, z, a, b, c);
      forceFeed();
    }
  } else {
    forceXYZ();
    var x = xOutput.format(_x);
    var y = yOutput.format(_y);
    var z = zOutput.format(_z);
    var i = ijkFormat.format(_a);
    var j = ijkFormat.format(_b);
    var k = ijkFormat.format(_c);
    if (x || y || z || i || j || k) {
      if (getProperty("isnc") && !forceG0) {
        // axes are not synchronized
        writeBlock(gMotionModal.format(1), x, y, z, "I" + i, "J" + j, "K" + k, feedOutput.format(highFeedrate));
      } else {
        writeBlock(gMotionModal.format(0), x, y, z, "I" + i, "J" + j, "K" + k);
        forceFeed();
      }
    }
  }
}

function onLinear5D(_x, _y, _z, _a, _b, _c, feed) {
  edgeFeed.flush();
  if (pendingRadiusCompensation >= 0) {
    error(localize("Radius compensation cannot be activated/deactivated for 5-axis move."));
    return;
  }

  if (currentSection.isOptimizedForMachine()) {
    var x = xOutput.format(_x);
    var y = yOutput.format(_y);
    var z = zOutput.format(_z);
    var a = aOutput.format(_a);
    var b = bOutput.format(_b);
    var c = cOutput.format(_c);
    var f = getFeed(feed);
    if (x || y || z || a || b || c) {
      writeBlock(gMotionModal.format(1), x, y, z, a, b, c, f);
    } else if (f) {
      if (getNextRecord().isMotion()) { // try not to output feed without motion
        forceFeed(); // force feed on next line
      } else {
        writeBlock(gMotionModal.format(1), f);
      }
    }
  } else {
    forceXYZ();
    var x = xOutput.format(_x);
    var y = yOutput.format(_y);
    var z = zOutput.format(_z);
    var i = ijkFormat.format(_a);
    var j = ijkFormat.format(_b);
    var k = ijkFormat.format(_c);
    var f = getFeed(feed);
    if (x || y || z || i || j || k) {
      writeBlock(gMotionModal.format(1), x, y, z, "I" + i, "J" + j, "K" + k, f);
    } else if (f) {
      if (getNextRecord().isMotion()) { // try not to output feed without motion
        forceFeed(); // force feed on next line
      } else {
        writeBlock(gMotionModal.format(1), f);
      }
    }
  }
}

/**
  Writes a partial arc in the XY plane from the given start point. Must not use getCurrentPosition(),
  as the edge feed module calls it one or more moves late.
*/
function writeArcXY(clockwise, cx, cy, x, y, z, feed, start) {
  if (getProperty("isnc")) {
    writeBlock(gAbsIncModal.format(90), gPlaneModal.format(17), gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), yOutput.format(y), zOutput.format(z), irOutput.format(cx - start.x, 0), jrOutput.format(cy - start.y, 0), getFeed(feed));
  } else {
    writeBlock(gAbsIncModal.format(90), gPlaneModal.format(17), gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), yOutput.format(y), zOutput.format(z), iOutput.format(cx), jOutput.format(cy), getFeed(feed));
  }
}

function onCircular(clockwise, cx, cy, cz, x, y, z, feed) {
  // writeComment(toDeg(getCircularSweep()));
  if (pendingRadiusCompensation >= 0) {
    error(localize("Radius compensation cannot be activated/deactivated for a circular move."));
    return;
  }
  if (edgeFeed.onCircular(clockwise, cx, cy, cz, x, y, z, feed)) {
    return; // corner roll buffered by the edge feed module, written later through writeArcXY()
  }
  feed = edgeFeed.circularFeed(clockwise, cx, cy, cz, x, y, z, feed); // also flushes buffered moves

  var start = getCurrentPosition();

  if (isFullCircle()) {
    if (isHelical()) {
      linearize(tolerance);
      return;
    }
    switch (getCircularPlane()) {
    case PLANE_XY:
      if (getProperty("isnc")) {
        writeBlock(gAbsIncModal.format(90), gPlaneModal.format(17), gMotionModal.format(clockwise ? 2 : 3), irOutput.format(cx - start.x, 0), jrOutput.format(cy - start.y, 0), getFeed(feed));
      } else {
        writeBlock(gAbsIncModal.format(90), gPlaneModal.format(17), gMotionModal.format(clockwise ? 2 : 3), iOutput.format(cx), jOutput.format(cy), getFeed(feed));
      }
      break;
    case PLANE_ZX:
      if (getProperty("isnc")) {
        // right-handed
        writeBlock(gAbsIncModal.format(90), gPlaneModal.format(18), gMotionModal.format(clockwise ? 2 : 3), irOutput.format(cx - start.x, 0), krOutput.format(cz - start.z, 0), getFeed(feed));
      } else {
        // note: left hand coordinate system
        writeBlock(gAbsIncModal.format(90), gPlaneModal.format(18), gMotionModal.format(clockwise ? 3 : 2), iOutput.format(cx), kOutput.format(cz), getFeed(feed));
      }
      break;
    case PLANE_YZ:
      if (getProperty("isnc")) {
        writeBlock(gAbsIncModal.format(90), gPlaneModal.format(19), gMotionModal.format(clockwise ? 2 : 3), jrOutput.format(cy - start.y, 0), krOutput.format(cz - start.z, 0), getFeed(feed));
      } else {
        writeBlock(gAbsIncModal.format(90), gPlaneModal.format(19), gMotionModal.format(clockwise ? 2 : 3), jOutput.format(cy), kOutput.format(cz), getFeed(feed));
      }
      break;
    default:
      linearize(tolerance);
    }
  } else {
    switch (getCircularPlane()) {
    case PLANE_XY:
      writeArcXY(clockwise, cx, cy, x, y, z, feed, start);
      break;
    case PLANE_ZX:
      if (isHelical()) {
        linearize(tolerance);
        return;
      }

      if (getProperty("isnc")) {
        writeBlock(gAbsIncModal.format(90), gPlaneModal.format(18), gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), yOutput.format(y), zOutput.format(z), irOutput.format(cx - start.x, 0), krOutput.format(cz - start.z, 0), getFeed(feed));
      } else {
        // note: left hand coordinate system
        writeBlock(gAbsIncModal.format(90), gPlaneModal.format(18), gMotionModal.format(clockwise ? 3 : 2), xOutput.format(x), yOutput.format(y), zOutput.format(z), iOutput.format(cx), kOutput.format(cz), getFeed(feed));
      }
      break;
    case PLANE_YZ:
      if (isHelical()) {
        linearize(tolerance);
        return;
      }

      if (getProperty("isnc")) {
        writeBlock(gAbsIncModal.format(90), gPlaneModal.format(19), gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), yOutput.format(y), zOutput.format(z), jrOutput.format(cy - start.y, 0), krOutput.format(cz - start.z, 0), getFeed(feed));
      } else {
        writeBlock(gAbsIncModal.format(90), gPlaneModal.format(19), gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), yOutput.format(y), zOutput.format(z), jOutput.format(cy), kOutput.format(cz), getFeed(feed));
      }
      break;
    default:
      if (getProperty("allow3DArcs")) {
        // make sure maximumCircularSweep is well below 360deg
        // we could use G2.4 or G3.4 - direction is calculated
        var ip = getPositionU(0.5);
        writeBlock(gAbsIncModal.format(90), gMotionModal.format(clockwise ? 2.4 : 3.4), xOutput.format(ip.x), yOutput.format(ip.y), zOutput.format(ip.z));
        writeBlock(xOutput.format(x), yOutput.format(y), zOutput.format(z), getFeed(feed));
      } else {
        linearize(tolerance);
      }
    }
  }
}

var currentCoolantMode = COOLANT_OFF;
var coolantOff = undefined;

function setCoolant(coolant) {
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
  var multipleCoolantBlocks = new Array(); // create a formatted array to be passed into the outputted line
  if (!coolants) {
    error(localize("Coolants have not been defined."));
  }
  if (isProbeOperation()) { // avoid coolant output for probing
    coolant = COOLANT_OFF;
  }
  if (coolant == currentCoolantMode) {
    return undefined; // coolant is already active
  }
  if ((coolant != COOLANT_OFF) && (currentCoolantMode != COOLANT_OFF) && (coolantOff != undefined)) {
    if (Array.isArray(coolantOff)) {
      for (var i in coolantOff) {
        multipleCoolantBlocks.push(mFormat.format(coolantOff[i]));
      }
    } else {
      multipleCoolantBlocks.push(mFormat.format(coolantOff));
    }
  }

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

var mapCommand = {
  COMMAND_STOP:0,
  COMMAND_OPTIONAL_STOP:1,
  COMMAND_END:2,
  COMMAND_SPINDLE_CLOCKWISE:3,
  COMMAND_SPINDLE_COUNTERCLOCKWISE:4,
  COMMAND_STOP_SPINDLE:5,
  COMMAND_ORIENTATE_SPINDLE:19,
  COMMAND_LOAD_TOOL:6
};

function onCommand(command) {
  edgeFeed.flush();
  switch (command) {
  case COMMAND_STOP:
    writeBlock(mFormat.format(0));
    forceSpindleSpeed = true;
    return;
  case COMMAND_START_SPINDLE:
    onCommand(tool.clockwise ? COMMAND_SPINDLE_CLOCKWISE : COMMAND_SPINDLE_COUNTERCLOCKWISE);
    return;
  case COMMAND_LOCK_MULTI_AXIS:
    if (useMultiAxisFeatures && !machineConfiguration.isMultiAxisConfiguration()) {
      if (hasABCAxis("A")) {
        writeBlock(mFormat.format(32));
      }
      if (hasABCAxis("B")) {
        writeBlock(mFormat.format(34));
      }
      if (hasABCAxis("C")) {
        writeBlock(mFormat.format(12));
      }
    } else {
      if (aOutput.isEnabled()) {
        writeBlock(mFormat.format(32));
      }
      if (bOutput.isEnabled()) {
        writeBlock(mFormat.format(34));
      }
      if (cOutput.isEnabled()) {
        writeBlock(mFormat.format(12));
      }
    }
    return;
  case COMMAND_UNLOCK_MULTI_AXIS:
    if (useMultiAxisFeatures && !machineConfiguration.isMultiAxisConfiguration()) {
      if (hasABCAxis("A")) {
        writeBlock(mFormat.format(33));
      }
      if (hasABCAxis("B")) {
        writeBlock(mFormat.format(35));
      }
      if (hasABCAxis("C")) {
        writeBlock(mFormat.format(13));
      }
    } else {
      if (aOutput.isEnabled()) {
        writeBlock(mFormat.format(33));
      }
      if (bOutput.isEnabled()) {
        writeBlock(mFormat.format(35));
      }
      if (cOutput.isEnabled()) {
        writeBlock(mFormat.format(13));
      }
    }
    return;
  case COMMAND_START_CHIP_TRANSPORT:
    writeBlock(mFormat.format(59));
    return;
  case COMMAND_STOP_CHIP_TRANSPORT:
    writeBlock(mFormat.format(61));
    return;
  case COMMAND_BREAK_CONTROL:
    return;
  case COMMAND_TOOL_MEASURE:
    return;
  case COMMAND_PROBE_ON:
    return;
  case COMMAND_PROBE_OFF:
    return;
  }
  
  var stringId = getCommandStringId(command);
  var mcode = mapCommand[stringId];
  if (mcode != undefined) {
    writeBlock(mFormat.format(mcode));
  } else {
    onUnsupportedCommand(command);
  }
}

function onSectionEnd() {
  edgeFeed.onSectionEnd(); // writes any buffered move
  if (typeof inspectionProcessSectionEnd == "function") {
    inspectionProcessSectionEnd();
  }
  if (currentSection.isMultiAxis()) {
    writeBlock(mFormat.format(129));
    if (!isLastSection()) {
      writeBlock(mFormat.format(31)); // rotary axes encoder reset
    }
    // the code below gets the machine angles from previous operation.  closestABC must also be set to true
    if (currentSection.isOptimizedForMachine()) {
      currentMachineABC = currentSection.getFinalToolAxisABC();
    }
  }
  writeBlock(gPlaneModal.format(17));
  if (!isLastSection() && (getNextSection().getTool().coolant != tool.coolant)) {
    setCoolant(COOLANT_OFF);
  }
  if (((getCurrentSectionId() + 1) >= getNumberOfSections()) ||
      (tool.number != getNextSection().getTool().number)) {
    onCommand(COMMAND_BREAK_CONTROL);
  }

  if (isProbeOperation()) {
    writeBlock(gFormat.format(65), "P" + 9833); // spin the probe off
    if (angularProbingMode == ANGLE_PROBE_USE_CAXIS) {
      setProbingAngle(); // define rotation of part
    }
  }
  forceAny();
}

/** Output block to do safe retract and/or move to home position. */
function writeRetract() {
  var words = []; // store all retracted axes in an array
  var retractAxes = new Array(false, false, false);
  var method = getProperty("safePositionMethod");
  if (method == "clearanceHeight") {
    if (!is3D()) {
      error(localize("Retract option 'Clearance Height' is not supported for multi-axis machining."));
    } else {
      return;
    }
  }
  validate(arguments.length != 0, "No axis specified for writeRetract().");

  for (i in arguments) {
    retractAxes[arguments[i]] = true;
  }
  if ((retractAxes[0] || retractAxes[1]) && !retracted) { // retract Z first before moving to X/Y home
    error(localize("Retracting in X/Y is not possible without being retracted in Z."));
    return;
  }
  // special conditions
  /*
  if (retractAxes[2]) { // Z doesn't use G53
    method = "G28";
  }
  */

  // define home positions
  var _xHome;
  var _yHome;
  var _zHome;
  if (method == "G28") {
    _xHome = toPreciseUnit(0, MM);
    _yHome = toPreciseUnit(0, MM);
    _zHome = toPreciseUnit(0, MM);
  } else {
    _xHome = machineConfiguration.hasHomePositionX() ? machineConfiguration.getHomePositionX() : toPreciseUnit(0, MM);
    _yHome = machineConfiguration.hasHomePositionY() ? machineConfiguration.getHomePositionY() : toPreciseUnit(0, MM);
    _zHome = machineConfiguration.getRetractPlane() != 0 ? machineConfiguration.getRetractPlane() : toPreciseUnit(0, MM);
  }
  for (var i = 0; i < arguments.length; ++i) {
    switch (arguments[i]) {
    case X:
      words.push("X" + xyzFormat.format(_xHome));
      xOutput.reset();
      break;
    case Y:
      words.push("Y" + xyzFormat.format(_yHome));
      yOutput.reset();
      break;
    case Z:
      words.push("Z" + xyzFormat.format(_zHome));
      zOutput.reset();
      retracted = true;
      break;
    default:
      error(localize("Unsupported axis specified for writeRetract()."));
      return;
    }
  }
  if (words.length > 0) {
    switch (method) {
    case "G28":
      gMotionModal.reset();
      gAbsIncModal.reset();
      writeBlock(gFormat.format(28), gAbsIncModal.format(91), words);
      writeBlock(gAbsIncModal.format(90));
      break;
    case "G53":
      gMotionModal.reset();
      if (retractAxes[2] && useMultiAxisFeatures) {
        writeBlock(gFormat.format(0), mFormat.format(140));
        machineSimulation({mode:RETRACTTOOLAXIS}); // M140 retracts along the tool axis to the limit
      } else {
        writeBlock(gAbsIncModal.format(90), gFormat.format(53), gMotionModal.format(0), words);
        machineSimulation({
          x          : retractAxes[0] ? _xHome : undefined,
          y          : retractAxes[1] ? _yHome : undefined,
          z          : retractAxes[2] ? _zHome : undefined,
          coordinates: MACHINE
        });
      }
      break;
    default:
      error(localize("Unsupported safe position method."));
      return;
    }
  }
}

// Start of machine simulation connection move support (adapted from the Autodesk HURCO post, rev 45867)
var debugSimulation = false; // enable to output debug information for machine simulation calls in the NC program
var TOOLCHANGE = "TOOL CHANGE";
var RETRACTTOOLAXIS = "RETRACT TOOLAXIS";
var WORK = "WORK CS";
var MACHINE = "MACHINE CS";
var MIN = "MIN";
var MAX = "MAX";
var WARNING_NON_RANGE = [100, 101, 102];

/**
 * Sends connection moves that are not part of the toolpath (retracts, tool changes, G53 moves) to machine simulation.
 * This is a 3-axis machine, so TCP and tilted work planes are always off.
 * @param {Object} parameters
 *   x, y, z     : axis position, or MIN / MAX to move to the axis limit
 *   feed        : feedrate, true to use the current feed, false for rapid (default from the active G0/G1 mode)
 *   mode        : TOOLCHANGE | RETRACTTOOLAXIS
 *   coordinates : WORK | MACHINE (default WORK)
 */
function machineSimulation(parameters) {
  if (typeof revision != "number" || revision < 50198 || (getSimulationStreamPath() == "" && !debugSimulation)) {
    return; // unsupported post kernel or not simulating
  }
  var getAxisLimit = function(axis, limit) {
    var range = axis.getRange();
    if (range.isNonRange()) {
      var axisLetter = ["X", "Y", "Z"][axis.getCoordinate()];
      warningOnce(subst(localize("Machine simulation tried to move the \"%1\" axis to its limit, but its range is unlimited in the machine definition."), axisLetter), WARNING_NON_RANGE[axis.getCoordinate()]);
      return undefined;
    }
    return limit == MIN ? range.minimum : range.maximum;
  };
  var x = (isNaN(parameters.x) && parameters.x) ? getAxisLimit(machineConfiguration.getAxisX(), parameters.x) : parameters.x;
  var y = (isNaN(parameters.y) && parameters.y) ? getAxisLimit(machineConfiguration.getAxisY(), parameters.y) : parameters.y;
  var z = (isNaN(parameters.z) && parameters.z) ? getAxisLimit(machineConfiguration.getAxisZ(), parameters.z) : parameters.z;
  var mode = parameters.mode;
  if (mode !== undefined && mode != TOOLCHANGE && mode != RETRACTTOOLAXIS) {
    error(subst("Mode '%1' is not supported.", mode));
  }
  var feed = parameters.feed;
  if (feed === undefined) {
    feed = gMotionModal.getCurrent() != 0;
  }

  simulation.setTWPModeOff();
  simulation.setTCPModeOff();

  if (mode == RETRACTTOOLAXIS) {
    simulation.retractAlongToolAxisToLimit();
  }

  if (debugSimulation) {
    writeln("  DEBUG" + JSON.stringify(parameters));
  }

  if (x !== undefined || y !== undefined || z !== undefined) {
    if (x !== undefined) {simulation.setTargetX(x);}
    if (y !== undefined) {simulation.setTargetY(y);}
    if (z !== undefined) {simulation.setTargetZ(z);}
    if (feed) {
      simulation.setMotionToLinear();
      simulation.setFeedrate(typeof feed == "number" ? feed : (feedOutput.getCurrent() ? feedOutput.getCurrent() : highFeedrate));
    } else {
      simulation.setMotionToRapid();
    }
    if (parameters.coordinates == MACHINE) {
      simulation.moveToTargetInMachineCoords();
    } else {
      simulation.moveToTargetInWorkCoords();
    }
  }
  if (mode == TOOLCHANGE) {
    simulation.performToolChangeCycle();
    simulation.moveToTargetInMachineCoords();
  }
}
// End of machine simulation connection move support

function onClose() {
  edgeFeed.flush();
  nullProbeAngle(false);
  setCoolant(COOLANT_OFF);

  /*
  if (useMultiAxisFeatures && !is3D()) {
    writeBlock(gFormat.format(0), mFormat.format(140)); // retract
    writeBlock(
      gFormat.format(68.2),
      xOutput.format(0), yOutput.format(0), zOutput.format(0),
      "I" + ijkFormat.format(1), "J" + ijkFormat.format(0), "K" + ijkFormat.format(0),
      "U" + ijkFormat.format(0), "V" + ijkFormat.format(1), "W" + ijkFormat.format(0)
    );
    forceXYZ();
    gMotionModal.reset();
    writeBlock(
      gMotionModal.format(0), gFormat.format(8.2),
      xOutput.format(0), yOutput.format(0), zOutput.format(0),
      "I" + ijkFormat.format(0), "J" + ijkFormat.format(0), "K" + ijkFormat.format(1)
    );
  } else {
    writeBlock(gAbsIncModal.format(90), gFormat.format(53), "Z" + xyzFormat.format(0)); // retract
  }
*/

  writeRetract(Z);
  zOutput.reset();

//   writeRetract(X, Y);
  writeBlock(gAbsIncModal.format(90), gFormat.format(53), gMotionModal.format(0), "X" + xyzFormat.format(parkPosition.x), "Y" + xyzFormat.format(parkPosition.y));
  machineSimulation({x:parkPosition.x, y:parkPosition.y, coordinates:MACHINE});
  
  onCommand(COMMAND_UNLOCK_MULTI_AXIS);
  writeBlock(gFormat.format(69)); // cancel frame
  writeBlock(mFormat.format(31)); // rotary axes encoder reset


  writeBlock(
    gMotionModal.format(0),
    conditional(machineConfiguration.isMachineCoordinate(0), "A" + abcFormat.format(0)),
    conditional(machineConfiguration.isMachineCoordinate(1), "B" + abcFormat.format(0)),
    conditional(machineConfiguration.isMachineCoordinate(2), "C" + abcFormat.format(0))
  );

  onCommand(COMMAND_LOCK_MULTI_AXIS);

  if (forceMultiAxisIndexing || !is3D() || machineConfiguration.isMultiAxisConfiguration()) {
    writeBlock(mFormat.format(127)); // cancel shortest path traverse
  }

  writeln("DPRNT[LOG-HURCO VM10I-PROGRAM STOP]");
  writeln("PCLOS");
  onCommand(COMMAND_STOP_CHIP_TRANSPORT);
  onImpliedCommand(COMMAND_END);
  onImpliedCommand(COMMAND_STOP_SPINDLE);
  writeBlock(mFormat.format(2)); // end of program, stop spindle, coolant off
  writeln("E");
}
