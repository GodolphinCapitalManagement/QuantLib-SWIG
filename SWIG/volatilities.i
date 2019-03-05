/*
 Copyright (C) 2000, 2001, 2002, 2003 RiskMap srl
 Copyright (C) 2008 StatPro Italia srl
 Copyright (C) 2011 Lluis Pujol Bajador
 Copyright (C) 2015 Matthias Groncki
 Copyright (C) 2016 Peter Caspers
 Copyright (C) 2018 Matthias Lungwitz

 This file is part of QuantLib, a free-software/open-source library
 for financial quantitative analysts and developers - http://quantlib.org/

 QuantLib is free software: you can redistribute it and/or modify it
 under the terms of the QuantLib license.  You should have received a
 copy of the license along with this program; if not, please email
 <quantlib-dev@lists.sf.net>. The license is also available online at
 <http://quantlib.org/license.shtml>.

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
*/

#ifndef quantlib_volatilities_i
#define quantlib_volatilities_i

%include common.i
%include date.i
%include daycounters.i
%include types.i
%include currencies.i
%include observer.i
%include marketelements.i
%include interpolation.i
%include indexes.i
%include optimizers.i
%include options.i
%include boost_shared_ptr.i

%define QL_TYPECHECK_VOLATILITYTYPE       8210    %enddef

%{
using QuantLib::VolatilityType;
using QuantLib::ShiftedLognormal;
using QuantLib::Normal;
%}

enum VolatilityType { ShiftedLognormal, Normal};

#if defined(SWIGPYTHON)
%typemap(in) boost::optional<VolatilityType> %{
    if($input == Py_None)
        $1 = boost::none;
    else if (PyInt_Check($input))
        $1 = (VolatilityType) PyInt_AsLong($input);
    else
        $1 = (VolatilityType) PyLong_AsLong($input);
%}
%typecheck (QL_TYPECHECK_VOLATILITYTYPE) boost::optional<VolatilityType> {
if (PyInt_Check($input) || PyLong_Check($input) || Py_None == $input)
    $1 = 1;
else
    $1 = 0;
}
#endif

%{
using QuantLib::VolatilityTermStructure;
using QuantLib::BlackVolTermStructure;
using QuantLib::LocalVolTermStructure;
using QuantLib::OptionletVolatilityStructure;
using QuantLib::SwaptionVolatilityStructure;
%}

%shared_ptr(VolatilityTermStructure);
class VolatilityTermStructure : public Observable {
  private:
    VolatilityTermStructure();
  public:
    // from TermStructure, to be defined later
    Date referenceDate() const;
    DayCounter dayCounter() const;
    Calendar calendar() const;
    Date maxDate() const;
    Time maxTime() const;

    // from Extrapolator, since we can't use multiple inheritance
    void enableExtrapolation();
    void disableExtrapolation();
    bool allowsExtrapolation();

    // own methods
    Real minStrike() const;
    Real maxStrike() const;
};


%shared_ptr(BlackVolTermStructure);
class BlackVolTermStructure : public VolatilityTermStructure {
  private:
    BlackVolTermStructure();
  public:
    Volatility blackVol(const Date&, Real strike,
                        bool extrapolate = false) const;
    Volatility blackVol(Time, Real strike,
                        bool extrapolate = false) const;
    Real blackVariance(const Date&, Real strike,
                       bool extrapolate = false) const;
    Real blackVariance(Time, Real strike,
                       bool extrapolate = false) const;
    Volatility blackForwardVol(const Date&, const Date&,
                               Real strike, bool extrapolate = false) const;
    Volatility blackForwardVol(Time, Time, Real strike,
                               bool extrapolate = false) const;
    Real blackForwardVariance(const Date&, const Date&,
                              Real strike, bool extrapolate = false) const;
    Real blackForwardVariance(Time, Time, Real strike,
                              bool extrapolate = false) const;
};

%template(BlackVolTermStructureHandle) Handle<BlackVolTermStructure>;
%template(RelinkableBlackVolTermStructureHandle) RelinkableHandle<BlackVolTermStructure>;


%shared_ptr(LocalVolTermStructure);
class LocalVolTermStructure : public VolatilityTermStructure {
  private:
    LocalVolTermStructure();
  public:
    Volatility localVol(const Date&, Real u,
                        bool extrapolate = false) const;
    Volatility localVol(Time, Real u,
                        bool extrapolate = false) const;
};

%template(LocalVolTermStructureHandle) Handle<LocalVolTermStructure>;
%template(RelinkableLocalVolTermStructureHandle) RelinkableHandle<LocalVolTermStructure>;


%shared_ptr(OptionletVolatilityStructure);
class OptionletVolatilityStructure : public VolatilityTermStructure {
  private:
    OptionletVolatilityStructure();
  public:
    Volatility volatility(const Date&, Real strike,
                          bool extrapolate = false) const;
    Volatility volatility(Time, Real strike,
                          bool extrapolate = false) const;
    Real blackVariance(const Date&, Rate strike,
                       bool extrapolate = false) const ;
    Real blackVariance(Time, Rate strike,
                       bool extrapolate = false) const;
};

%template(OptionletVolatilityStructureHandle) Handle<OptionletVolatilityStructure>;
%template(RelinkableOptionletVolatilityStructureHandle) RelinkableHandle<OptionletVolatilityStructure>;


%{
using QuantLib::SwaptionVolatilityStructure;
%}

%shared_ptr(SwaptionVolatilityStructure);
class SwaptionVolatilityStructure : public VolatilityTermStructure {
  private:
    SwaptionVolatilityStructure();
  public:
    Volatility volatility(const Date& start, const Period& length,
                          Rate strike, bool extrapolate = false) const;
    Volatility volatility(Time start, Time length,
                          Rate strike, bool extrapolate = false) const;
    Real blackVariance(const Date& start, const Period& length,
                       Rate strike, bool extrapolate = false) const;
    Real blackVariance(Time start, Time length,
                       Rate strike, bool extrapolate = false) const;
    Date optionDateFromTenor(const Period& p) const;
};

%template(SwaptionVolatilityStructureHandle) Handle<SwaptionVolatilityStructure>;
%template(RelinkableSwaptionVolatilityStructureHandle) RelinkableHandle<SwaptionVolatilityStructure>;



// actual term structures below

// constant Black vol term structure
%{
using QuantLib::BlackConstantVol;
%}

%shared_ptr(BlackConstantVol);
class BlackConstantVol : public BlackVolTermStructure {
  public:
    BlackConstantVol(const Date& referenceDate,
                     const Calendar & c,
                     Volatility volatility,
                     const DayCounter& dayCounter);
    BlackConstantVol(const Date& referenceDate,
                     const Calendar &c,
                     const Handle<Quote>& volatility,
                     const DayCounter& dayCounter);
    BlackConstantVol(Natural settlementDays, const Calendar& calendar,
                     Volatility volatility,
                     const DayCounter& dayCounter);
    BlackConstantVol(Natural settlementDays, const Calendar& calendar,
                     const Handle<Quote>& volatility,
                     const DayCounter& dayCounter);
};

// Black ATM curve

%{
using QuantLib::BlackVarianceCurve;
%}

%shared_ptr(BlackVarianceCurve);
class BlackVarianceCurve : public BlackVolTermStructure {
  public:
    BlackVarianceCurve(const Date& referenceDate,
                       const std::vector<Date>& dates,
                       const std::vector<Real>& volatilities,
                       const DayCounter& dayCounter,
                       bool forceMonotoneVariance = true);
};



// Black smiled surface
%{
using QuantLib::BlackVarianceSurface;
%}

%shared_ptr(BlackVarianceSurface);
class BlackVarianceSurface : public BlackVolTermStructure {
    #if !defined(SWIGJAVA) && !defined(SWIGCSHARP)
    %feature("kwargs") BlackVarianceSurface;
    #endif
  public:
    enum Extrapolation { ConstantExtrapolation,
                         InterpolatorDefaultExtrapolation };
    %extend {
        BlackVarianceSurface(
                const Date& referenceDate,
                const Calendar & cal,
                const std::vector<Date>& dates,
                const std::vector<Real>& strikes,
                const Matrix& blackVols,
                const DayCounter& dayCounter,
                BlackVarianceSurface::Extrapolation lower =
                    BlackVarianceSurface::InterpolatorDefaultExtrapolation,
                BlackVarianceSurface::Extrapolation upper =
                    BlackVarianceSurface::InterpolatorDefaultExtrapolation,
                const std::string& interpolator = "") {
            BlackVarianceSurface* surface =
                new BlackVarianceSurface(referenceDate,cal,
                                         dates,strikes,
                                         blackVols,dayCounter,lower,upper);
            std::string s = boost::algorithm::to_lower_copy(interpolator);
            if (s == "" || s == "bilinear") {
                surface->setInterpolation<QuantLib::Bilinear>();
            } else if (s == "bicubic") {
                surface->setInterpolation<QuantLib::Bicubic>();
            } else {
                QL_FAIL("Unknown interpolator: " << interpolator);
            }
            return surface;
        }
        void setInterpolation(const std::string& interpolator = "") {
            std::string s = boost::algorithm::to_lower_copy(interpolator);
            if (s == "" || s == "bilinear") {
                self->setInterpolation<QuantLib::Bilinear>();
            } else if (s == "bicubic") {
                self->setInterpolation<QuantLib::Bicubic>();
            } else {
                QL_FAIL("Unknown interpolator: " << interpolator);
            }
        }
    }
};



// constant local vol term structure
%{
using QuantLib::LocalConstantVol;
%}

%shared_ptr(LocalConstantVol);
class LocalConstantVol : public LocalVolTermStructure {
  public:
    LocalConstantVol(const Date& referenceDate, Volatility volatility,
                     const DayCounter& dayCounter);
    LocalConstantVol(const Date& referenceDate,
                     const Handle<Quote>& volatility,
                     const DayCounter& dayCounter);
    LocalConstantVol(Integer settlementDays, const Calendar& calendar,
                     Volatility volatility,
                     const DayCounter& dayCounter);
    LocalConstantVol(Integer settlementDays, const Calendar& calendar,
                     const Handle<Quote>& volatility,
                     const DayCounter& dayCounter);
};



// local vol surface
%{
using QuantLib::LocalVolSurface;
%}

%shared_ptr(LocalVolSurface);
class LocalVolSurface : public LocalVolTermStructure {
  public:
    LocalVolSurface(const Handle<BlackVolTermStructure>& blackTS,
                    const Handle<YieldTermStructure>& riskFreeTS,
                    const Handle<YieldTermStructure>& dividendTS,
                    const Handle<Quote>& underlying);
    LocalVolSurface(const Handle<BlackVolTermStructure>& blackTS,
                    const Handle<YieldTermStructure>& riskFreeTS,
                    const Handle<YieldTermStructure>& dividendTS,
                    Real underlying);
};


// constant caplet constant term structure
%{
using QuantLib::ConstantOptionletVolatility;
%}

%shared_ptr(ConstantOptionletVolatility);
class ConstantOptionletVolatility : public OptionletVolatilityStructure {
  public:
    ConstantOptionletVolatility(const Date& referenceDate,
                                const Calendar &cal,
                                BusinessDayConvention bdc,
                                Volatility volatility,
                                const DayCounter& dayCounter,
                                const VolatilityType type = ShiftedLognormal,
                                const Real shift = 0.0);
    ConstantOptionletVolatility(const Date& referenceDate,
                                const Calendar &cal,
                                BusinessDayConvention bdc,
                                const Handle<Quote>& volatility,
                                const DayCounter& dayCounter,
                                const VolatilityType type = ShiftedLognormal,
                                const Real shift = 0.0);
    ConstantOptionletVolatility(Natural settlementDays,
                                const Calendar &cal,
                                BusinessDayConvention bdc,
                                Volatility volatility,
                                const DayCounter& dayCounter,
                                const VolatilityType type = ShiftedLognormal,
                                const Real shift = 0.0);
    ConstantOptionletVolatility(Natural settlementDays,
                                const Calendar &cal,
                                BusinessDayConvention bdc,
                                const Handle<Quote>& volatility,
                                const DayCounter& dayCounter,
                                const VolatilityType type = ShiftedLognormal,
                                const Real shift = 0.0);
};



%{
using QuantLib::ConstantSwaptionVolatility;
%}

%shared_ptr(ConstantSwaptionVolatility);
class ConstantSwaptionVolatility : public SwaptionVolatilityStructure {
  public:
    ConstantSwaptionVolatility(Natural settlementDays,
                               const Calendar& cal,
                               BusinessDayConvention bdc,
                               const Handle<Quote>& volatility,
                               const DayCounter& dc,
                               const VolatilityType type = ShiftedLognormal,
                               const Real shift = 0.0);
    ConstantSwaptionVolatility(const Date& referenceDate,
                               const Calendar& cal,
                               BusinessDayConvention bdc,
                               const Handle<Quote>& volatility,
                               const DayCounter& dc,
                               const VolatilityType type = ShiftedLognormal,
                               const Real shift = 0.0);
    ConstantSwaptionVolatility(Natural settlementDays,
                               const Calendar& cal,
                               BusinessDayConvention bdc,
                               Volatility volatility,
                               const DayCounter& dc,
                               const VolatilityType type = ShiftedLognormal,
                               const Real shift = 0.0);
    ConstantSwaptionVolatility(const Date& referenceDate,
                               const Calendar& cal,
                               BusinessDayConvention bdc,
                               Volatility volatility,
                               const DayCounter& dc,
                               const VolatilityType type = ShiftedLognormal,
                               const Real shift = 0.0);
};

%{
using QuantLib::SwaptionVolatilityMatrix;
%}

%shared_ptr(SwaptionVolatilityMatrix);
class SwaptionVolatilityMatrix : public SwaptionVolatilityStructure {
  public:
    SwaptionVolatilityMatrix(const Date& referenceDate,
                             const std::vector<Date>& dates,
                             const std::vector<Period>& lengths,
                             const Matrix& vols,
                             const DayCounter& dayCounter,
                             const bool flatExtrapolation = false,
                             const VolatilityType type = ShiftedLognormal,
                             const Matrix& shifts = Matrix());
    SwaptionVolatilityMatrix(const Calendar& calendar,
                             BusinessDayConvention bdc,
                             const std::vector<Period>& optionTenors,
                             const std::vector<Period>& swapTenors,
                             const std::vector<std::vector<Handle<Quote> > >& vols,
                             const DayCounter& dayCounter,
                             const bool flatExtrapolation = false,
                             const VolatilityType type = ShiftedLognormal,
                             const std::vector<std::vector<Real> >& shifts =
                                          std::vector<std::vector<Real> >());
    SwaptionVolatilityMatrix(const Calendar& calendar,
                             BusinessDayConvention bdc,
                             const std::vector<Period>& optionTenors,
                             const std::vector<Period>& swapTenors,
                             const Matrix& vols,
                             const DayCounter& dayCounter,
                             const bool flatExtrapolation = false,
                             const VolatilityType type = ShiftedLognormal,
                             const Matrix& shifts = Matrix());
};

%{
using QuantLib::SwaptionVolCube1;
using QuantLib::SwaptionVolCube2;
%}

%shared_ptr(SwaptionVolCube1);
class SwaptionVolCube1 : public SwaptionVolatilityStructure {
  public:
    SwaptionVolCube1(
             const Handle<SwaptionVolatilityStructure>& atmVolStructure,
             const std::vector<Period>& optionTenors,
             const std::vector<Period>& swapTenors,
             const std::vector<Spread>& strikeSpreads,
             const std::vector<std::vector<Handle<Quote> > >& volSpreads,
             const boost::shared_ptr<SwapIndex>& swapIndex,
             const boost::shared_ptr<SwapIndex>& shortSwapIndex,
             bool vegaWeightedSmileFit,
             const std::vector<std::vector<Handle<Quote> > >& parametersGuess,
             const std::vector<bool>& isParameterFixed,
             bool isAtmCalibrated,
             const boost::shared_ptr<EndCriteria>& endCriteria
                                           = boost::shared_ptr<EndCriteria>(),
             Real maxErrorTolerance = Null<Real>(),
             const boost::shared_ptr<OptimizationMethod>& optMethod
                                  = boost::shared_ptr<OptimizationMethod>());
    Matrix sparseSabrParameters() const;
    Matrix denseSabrParameters() const;
    Matrix marketVolCube() const;
    Matrix volCubeAtmCalibrated() const;
};

%shared_ptr(SwaptionVolCube2);
class SwaptionVolCube2 : public SwaptionVolatilityStructure {
  public:
    SwaptionVolCube2(const Handle<SwaptionVolatilityStructure>& atmVolStructure,
                     const std::vector<Period>& optionTenors,
                     const std::vector<Period>& swapTenors,
                     const std::vector<Spread>& strikeSpreads,
                     const std::vector<std::vector<Handle<Quote> > >& volSpreads,
                     const boost::shared_ptr<SwapIndex>& swapIndex,
                     const boost::shared_ptr<SwapIndex>& shortSwapIndex,
                     bool vegaWeightedSmileFit);
};

%{
using QuantLib::SmileSection;
%}

%shared_ptr(SmileSection);

class SmileSection : public Observable {
  private:
    SmileSection();
  public:
    Real variance(Rate strike) const;
    Volatility volatility(Rate strike) const;
    virtual const Date& exerciseDate() const;
    virtual VolatilityType volatilityType() const;
    virtual Rate shift() const;
    virtual const Date& referenceDate() const;
    virtual Time exerciseTime() const;
    virtual const DayCounter& dayCounter();
    virtual Real optionPrice(Rate strike,
                             Option::Type type = Option::Call,
                             Real discount=1.0) const;
    virtual Real digitalOptionPrice(Rate strike,
                                    Option::Type type = Option::Call,
                                    Real discount=1.0,
                                    Real gap=1.0e-5) const;
    virtual Real vega(Rate strike,
                      Real discount=1.0) const;
    virtual Real density(Rate strike,
                         Real discount=1.0,
                         Real gap=1.0E-4) const;
    Volatility volatility(Rate strike, VolatilityType type, Real shift=0.0) const;
};

%{
using QuantLib::FlatSmileSection;
%}

%shared_ptr(FlatSmileSection)

class FlatSmileSection : public SmileSection {
  public:
    FlatSmileSection(const Date& d,
                     Volatility vol,
                     const DayCounter& dc,
                     const Date& referenceDate = Date(),
                     Real atmLevel = Null<Rate>(),
                     VolatilityType type = ShiftedLognormal,
                     Real shift = 0.0);
    FlatSmileSection(Time exerciseTime,
                     Volatility vol,
                     const DayCounter& dc,
                     Real atmLevel = Null<Rate>(),
                     VolatilityType type = ShiftedLognormal,
                     Real shift = 0.0);
};

%{
using QuantLib::InterpolatedSmileSection;
using QuantLib::Actual365Fixed;
%}

template<class Interpolator>
class InterpolatedSmileSection : public SmileSection {
  public:
    InterpolatedSmileSection(
               Time expiryTime,
               const std::vector<Rate>& strikes,
               const std::vector<Handle<Quote> >& stdDevHandles,
               const Handle<Quote>& atmLevel,
               const Interpolator& interpolator = Interpolator(),
               const DayCounter& dc = Actual365Fixed(),
               const VolatilityType type = ShiftedLognormal,
               const Real shift = 0.0);
    InterpolatedSmileSection(
               Time expiryTime,
               const std::vector<Rate>& strikes,
               const std::vector<Real>& stdDevs,
               Real atmLevel,
               const Interpolator& interpolator = Interpolator(),
               const DayCounter& dc = Actual365Fixed(),
               const VolatilityType type = ShiftedLognormal,
               const Real shift = 0.0);
    InterpolatedSmileSection(
               const Date& d,
               const std::vector<Rate>& strikes,
               const std::vector<Handle<Quote> >& stdDevHandles,
               const Handle<Quote>& atmLevel,
               const DayCounter& dc = Actual365Fixed(),               
               const Interpolator& interpolator = Interpolator(),
               const Date& referenceDate = Date(),
               const VolatilityType type = ShiftedLognormal,
               const Real shift = 0.0);
    InterpolatedSmileSection(
               const Date& d,
               const std::vector<Rate>& strikes,
               const std::vector<Real>& stdDevs,
               Real atmLevel,
               const DayCounter& dc = Actual365Fixed(),
               const Interpolator& interpolator = Interpolator(),
               const Date& referenceDate = Date(),
               const VolatilityType type = ShiftedLognormal,
               const Real shift = 0.0);
};

%define export_smileinterpolation_curve(Name,Interpolator)
%shared_ptr(InterpolatedSmileSection<Interpolator>)
%template(Name) InterpolatedSmileSection<Interpolator>;
%enddef

export_smileinterpolation_curve(LinearInterpolatedSmileSection, Linear);
export_smileinterpolation_curve(CubicInterpolatedSmileSection, Cubic);
export_smileinterpolation_curve(MonotonicCubicInterpolatedSmileSection, MonotonicCubic);
export_smileinterpolation_curve(SplineCubicInterpolatedSmileSection, SplineCubic);

%{
using QuantLib::SabrSmileSection;
%}

%shared_ptr(SabrSmileSection)

class SabrSmileSection : public SmileSection {
  public:
    SabrSmileSection(const Date& d,
                     Rate forward,
                     const std::vector<Real>& sabrParameters,
                     const DayCounter& dc = Actual365Fixed(),
                     Real shift = 0.0);
    SabrSmileSection(Time timeToExpiry,
                     Rate forward,
                     const std::vector<Real>& sabrParameters,
                     Real shift = 0.0);
};

%{
using QuantLib::KahaleSmileSection;
%}

%shared_ptr(KahaleSmileSection)

class KahaleSmileSection : public SmileSection {
  public:
    KahaleSmileSection(const boost::shared_ptr<SmileSection> source,
                       const Real atm = Null<Real>(),
                       const bool interpolate = false,
                       const bool exponentialExtrapolation = false,
                       const bool deleteArbitragePoints = false,
                       const std::vector<Real> &moneynessGrid = std::vector<Real>(),
                       const Real gap = 1.0E-5,
                       const int forcedLeftIndex = -1,
                       const int forcedRightIndex = QL_MAX_INTEGER);
};

%{
using QuantLib::ZabrShortMaturityLognormal;
using QuantLib::ZabrShortMaturityNormal;
using QuantLib::ZabrLocalVolatility;
using QuantLib::ZabrFullFd;
using QuantLib::ZabrSmileSection;
using QuantLib::ZabrInterpolatedSmileSection;
using QuantLib::NoArbSabrSmileSection;
using QuantLib::NoArbSabrInterpolatedSmileSection;
using QuantLib::Option;
%}

struct ZabrShortMaturityLognormal {};
struct ZabrShortMaturityNormal {};
struct ZabrLocalVolatility {};
struct ZabrFullFd {};

template <class Evaluation>
class ZabrSmileSection : public SmileSection {
  public:
    ZabrSmileSection(
               Time timeToExpiry, 
               Rate forward,
               const std::vector<Real> &zabrParameters,
               const std::vector<Real> &moneyness = std::vector<Real>(),
               const Size fdRefinement = 5);
    ZabrSmileSection(
               const Date &d, 
               Rate forward,
               const std::vector<Real> &zabrParameters,
               const DayCounter &dc = Actual365Fixed(),
               const std::vector<Real> &moneyness = std::vector<Real>(),
               const Size fdRefinement = 5);
};

%define export_zabrsmilesection_curve(Name,Evaluation)
%shared_ptr(ZabrSmileSection<Evaluation>)
%template(Name) ZabrSmileSection<Evaluation>;
%enddef

export_zabrsmilesection_curve(ZabrShortMaturityLognormalSmileSection, ZabrShortMaturityLognormal);
export_zabrsmilesection_curve(ZabrShortMaturityNormalSmileSection, ZabrShortMaturityNormal);
export_zabrsmilesection_curve(ZabrLocalVolatilitySmileSection, ZabrLocalVolatility);
export_zabrsmilesection_curve(ZabrFullFdSmileSection, ZabrFullFd);


template <class Evaluation>
class ZabrInterpolatedSmileSection : public SmileSection {
  public:
    ZabrInterpolatedSmileSection(
               const Date &optionDate, const Handle<Quote> &forward,
               const std::vector<Rate> &strikes, bool hasFloatingStrikes,
               const Handle<Quote> &atmVolatility,
               const std::vector<Handle<Quote> > &volHandles, Real alpha, Real beta,
               Real nu, Real rho, Real gamma, bool isAlphaFixed = false,
               bool isBetaFixed = false, bool isNuFixed = false,
               bool isRhoFixed = false, bool isGammaFixed = false,
               bool vegaWeighted = true,
               const boost::shared_ptr<EndCriteria> &endCriteria =
               boost::shared_ptr<EndCriteria>(),
               const boost::shared_ptr<OptimizationMethod> &method =
               boost::shared_ptr<OptimizationMethod>(),
               const DayCounter &dc = Actual365Fixed());
    ZabrInterpolatedSmileSection(
               const Date &optionDate, const Rate &forward,
               const std::vector<Rate> &strikes, bool hasFloatingStrikes,
               const Volatility &atmVolatility, const std::vector<Volatility> &vols,
               Real alpha, Real beta, Real nu, Real rho, Real gamma,
               bool isAlphaFixed = false, bool isBetaFixed = false,
               bool isNuFixed = false, bool isRhoFixed = false,
               bool isGammaFixed = false, bool vegaWeighted = true,
               const boost::shared_ptr<EndCriteria> &endCriteria =
               boost::shared_ptr<EndCriteria>(),
               const boost::shared_ptr<OptimizationMethod> &method =
               boost::shared_ptr<OptimizationMethod>(),
               const DayCounter &dc = Actual365Fixed());
    Real alpha() const;
    Real beta() const;
    Real nu() const;
    Real rho() const;
    Real rmsError() const;
    Real maxError() const;
    EndCriteria::Type endCriteria() const;
};

%define export_zabrinterpolatedsmilesection_curve(Name,Evaluation)
%shared_ptr(ZabrInterpolatedSmileSection<Evaluation>)
%template(Name) ZabrInterpolatedSmileSection<Evaluation>;
%enddef

export_zabrinterpolatedsmilesection_curve(ZabrShortMaturityLognormalInterpolatedSmileSection, ZabrShortMaturityLognormal);
export_zabrinterpolatedsmilesection_curve(ZabrShortMaturityNormalInterpolatedSmileSection, ZabrShortMaturityNormal);
export_zabrinterpolatedsmilesection_curve(ZabrLocalVolatilityInterpolatedSmileSection, ZabrLocalVolatility);
export_zabrinterpolatedsmilesection_curve(ZabrFullFdInterpolatedSmileSection, ZabrFullFd);


%shared_ptr(NoArbSabrSmileSection)

class NoArbSabrSmileSection : public SmileSection {
  public:
    NoArbSabrSmileSection(
               Time timeToExpiry, 
               Rate forward,
               const std::vector<Real> &sabrParameters,
               const Real shift = 0.0);
    NoArbSabrSmileSection(
               const Date &d, 
               Rate forward,
               const std::vector<Real> &sabrParameters,
               const DayCounter &dc = Actual365Fixed(),
               const Real shift = 0.0);
};

%shared_ptr(NoArbSabrInterpolatedSmileSection)

class NoArbSabrInterpolatedSmileSection : public SmileSection {
  public:
    NoArbSabrInterpolatedSmileSection(
               const Date &optionDate, const Handle<Quote> &forward,
               const std::vector<Rate> &strikes, bool hasFloatingStrikes,
               const Handle<Quote> &atmVolatility,
               const std::vector<Handle<Quote> > &volHandles, Real alpha, Real beta,
               Real nu, Real rho, bool isAlphaFixed = false,
               bool isBetaFixed = false, bool isNuFixed = false,
               bool isRhoFixed = false,
               bool vegaWeighted = true,
               const boost::shared_ptr<EndCriteria> &endCriteria =
               boost::shared_ptr<EndCriteria>(),
               const boost::shared_ptr<OptimizationMethod> &method =
               boost::shared_ptr<OptimizationMethod>(),
               const DayCounter &dc = Actual365Fixed());
    NoArbSabrInterpolatedSmileSection(
               const Date &optionDate, const Rate &forward,
               const std::vector<Rate> &strikes, bool hasFloatingStrikes,
               const Volatility &atmVolatility, const std::vector<Volatility> &vols,
               Real alpha, Real beta, Real nu, Real rho,
               bool isAlphaFixed = false, bool isBetaFixed = false,
               bool isNuFixed = false, bool isRhoFixed = false,
               bool vegaWeighted = true,
               const boost::shared_ptr<EndCriteria> &endCriteria =
               boost::shared_ptr<EndCriteria>(),
               const boost::shared_ptr<OptimizationMethod> &method =
               boost::shared_ptr<OptimizationMethod>(),
               const DayCounter &dc = Actual365Fixed());
    Real alpha() const;
    Real beta() const;
    Real nu() const;
    Real rho() const;
    Real rmsError() const;
    Real maxError() const;
    EndCriteria::Type endCriteria() const;
};

#endif
