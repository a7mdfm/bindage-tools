package com.googlecode.bindagetools.impl {
import com.googlecode.bindagetools.BindGroup;
import com.googlecode.bindagetools.IPipeline;
import com.googlecode.bindagetools.IPipelineBuilder;
import com.googlecode.bindagetools.IPipelineBuilderFactory;
import com.googlecode.bindagetools.IPropertyPipelineBuilder;

public class PipelineBuilderFactory implements IPipelineBuilderFactory {

  private var _nextTime:Boolean;

  public function PipelineBuilderFactory(nextTime:Boolean = false) {
    _nextTime = nextTime;
  }

  public function nextTime():IPipelineBuilderFactory {
    return new PipelineBuilderFactory(true);
  }

  /**
   * Returns a new binding pipeline builder, which binds from the specified property of the given
   * source
   * object.
   *
   * @param source the object that hosts the property to be watched.
   * @param property an object specifying the property to be watched on the source object.  Valid
   * values include:
   * <ul>
   * <li>A String containing name(s) of a public bindable property of the source object.  Nested
   * properties may be expressed using dot notation e.g. "foo.bar.baz"</li>
   * <li>An Object in the form:<br/>
   * <pre>
   * { name: <i>property name</i>,
   *   getter: function(source):* { <i>return property value</i> } }
   * </pre>
   * </li>
   * <li>If <code>additionalProperties</code> is omitted, an Array containing the above
   * elements.</li>
   * </ul>
   * @param additionalProperties (optional) any additional properties in the source property chain.
   * Valid values are same as the <code>property</code> parameter.
   * @return the new binding pipeline builder.
   * @throws ArgumentError if source is null, or if any element of properties is null or not a
   * valid value.
   */
  public function fromProperty(source:Object, property:Object,
                               ... additionalProperties):IPropertyPipelineBuilder {
    var properties:Array;
    if (property is Array && additionalProperties.length == 0) {
      properties = property as Array;
    }
    else {
      properties = [property].concat(additionalProperties);
    }

    return new PropertyPipelineBuilder(source, properties, _nextTime);
  }

  /**
   * Returns a new binding pipeline builder, which binds from all the specified source pipelines.
   *
   * <p>
   * Example:
   * </p>
   * <pre>
   * Bind.fromAll(
   *     Bind.fromProperty(normalPriceInput, "text")
   *         .validate(isNumber())
   *         .convert(toNumber)
   *         .validate(greaterThan(0)),
   *     Bind.fromProperty(discountPriceInput, "text")
   *         .validate(isNumber())
   *         .convert(toNumber)
   *     )
   *     .convert(function(normalPrice:Number, discountPrice:Number):String {
   *       return (100 * (normalPrice - discountPrice) / normalPrice) + '%';
   *     })
   *     .toProperty(discountPercentText, 'text');
   * </pre>
   *
   * <p>
   * Note that the custom converter function takes two arguments.  This is because there are two
   * bindings pipelines specified as sources in the <code>Bind.fromAll</code> call.  The values
   * from each source pipeline are passed as arguments to the steps in the binding pipelines, in
   * the same order as they are specified in the <code>fromAll</code> call.  If the master pipeline
   * has a <code>convert()</code> step, then all arguments are combined into a single value.
   * Otherwise, all values continue to be passed to each step including the final property setter
   * or setter function.
   * </p>
   *
   * @param sources an array of IPipelineBuilder instances.
   * @return the new binding pipeline builder.
   */
  public function fromAll(... pipelines):IPipelineBuilder {
    return new MultiPipelineBuilder(pipelines, _nextTime);
  }

  /**
   * Creates a two-way binding between the specified pipelines.
   *
   * @param source the source pipeline from which the target will be initially populated.
   * @param target the target pipeline which will be initially populated from the source
   * @param group (optional) the BindGroup that each binding will belong to.  Grouping bindings
   * ensures that only one binding in a group may execute at a time.  If this parameter is
   * omitted, a BindGroup will be provided automatically.
   * @throws ArgumentError if either source or target is not an IPropertyPipeline instance.
   */
  public function twoWay(source:IPipelineBuilder, target:IPipelineBuilder,
                         group:BindGroup = null):void {
    if (!(source is IPropertyPipelineBuilder)) {
      throw new ArgumentError("Source pipeline must originate from a single property");
    }
    if (!(target is IPropertyPipelineBuilder)) {
      throw new ArgumentError("Target pipeline must originate from a single property");
    }

    if (group == null) {
      group = new BindGroup();
    }

    source.group(group);
    target.group(group);

    var sourcePipeline:IPropertyPipelineBuilder = IPropertyPipelineBuilder(source);
    var targetPipeline:IPropertyPipelineBuilder = IPropertyPipelineBuilder(target);

    var sourceSetter:IPipeline = new SetterPipeline(sourcePipeline.source,
                                                    sourcePipeline.properties);
    var targetSetter:IPipeline = new SetterPipeline(targetPipeline.source,
                                                    targetPipeline.properties);

    var sourceToTargetRunner:Function = source.runner(targetSetter);
    var targetToSourceRunner:Function = target.runner(sourceSetter);

    source.watch(sourceToTargetRunner);
    target.watch(targetToSourceRunner);

    if (!_nextTime) {
      sourceToTargetRunner();
    }
  }

}
}
