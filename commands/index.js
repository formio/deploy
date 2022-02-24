module.exports = (program) => {
    require('./package')(program),
    require('./run')(program),
    require('./push')(program)
};